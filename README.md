# Data-engineering-Note
 
- Useful link
  - Data engineering basic idea
    - [資料科學家為何需要了解資料工程](https://leemeng.tw/why-you-need-to-learn-data-engineering-as-a-data-scientist.html)
  - Airflow basic
    - [Scheduling a SQL script, using Apache Airflow, with an example](https://www.startdataengineering.com/post/how-to-schedule-a-sql-script-using-apache-airflow-with-an-example/)
    - [一段 Airflow 與資料工程的故事：談如何用 Python 追漫畫連載](https://leemeng.tw/a-story-about-airflow-and-data-engineering-using-how-to-use-python-to-catch-up-with-latest-comics-as-an-example.html)
   - Amazon Kinesis
     - [利用 Kinesis 處理串流資料並建立資料湖](https://leemeng.tw/use-kinesis-streams-and-firehose-to-build-a-data-lake.html)
     - 可以把Kinesis Data Stream裡的shards想成港口，港口越多吞吐量越大，而Firehose delivery stream則是把貨物(資料)運送到目的地的船隻
   - Pyspark
     - [《巨量資料技術與應用-Spark (Python篇)》實務操作講義- RDD運作基礎](http://debussy.im.nuu.edu.tw/sjchen/BigData-Spark/%E5%B7%A8%E9%87%8F%E8%B3%87%E6%96%99%E6%8A%80%E8%A1%93%E8%88%87%E6%87%89%E7%94%A8%E6%93%8D%E4%BD%9C%E8%AC%9B%E7%BE%A9-RDD%E9%81%8B%E4%BD%9C%E5%9F%BA%E7%A4%8E.html)
     - [PySpark Tutorial](https://sparkbyexamples.com/)
     - [Pyspark API reference](https://spark.apache.org/docs/latest/api/python/reference/index.html)
     - [Spark簡介](http://debussy.im.nuu.edu.tw/sjchen/BigData/Spark.pdf)
     - [Spark架構與原理這一篇就夠了](https://iter01.com/553814.html)
     - [Apache Spark Performance Boosting](https://towardsdatascience.com/apache-spark-performance-boosting-e072a3ec1179)
- pyspark
  - overview
    - Spark包含1個driver和若干個exexutor（在各個節點上）(master-slave architecture, the master is the driver, and slaves are the executors.)
    - Driver會把計算任務分成一系列小的task，然後送到executor執行。executor之間可以通信，在每個executor完成自己的task以後，所有的信息會被傳回。
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/spark_structure.png" width="500" height="300"/>
   - spark basic architecture
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/pyspark%E6%9E%B6%E6%A7%8B.png" width="900" height="500"/>
     
     1. After submitting the job through SparkSubmit, the Client starts to build the spark context(SparkContext是Spark的入口，相當於應用程序的main函數), that is, the execution environment of the application
     2. SparkContext connects to the ClusterManager, registers and applies for the resources (core and memory) to execute the Executor
     3. The ClusterManager decides on which worker to start the executor according to the application made by SparkContext and the heartbeat report of the worker(ClusterManager根據SparkContext提出的申請，根據worker的心跳報告，來決定到底在那個worker上啟動executor)
     4. After the worker node receives the request, it will start the executor
     5. The executor registers with the SparkContext, so that the driver knows which executors execute the application
     6. SparkContext transfers Application code to executor
     7. At the same time, SparkContext parses the Application code, builds a DAG graph, submits it to DAGScheduler for decomposition into stages, and the stage is sent to TaskScheduler
     8. The TaskScheduler is responsible for assigning the Task to the corresponding worker, and finally submitting it to the executor for execution
     9. The executor will start executing tasks, and report to SparkContext until all tasks are executed
     10. After all tasks are completed, SparkContext logs out to the ClusterManager
  
  - Jobs, stages, tasks
     - An Application consists of a Driver and several Jobs, and a Job consists of multiple Stages
     - When executing an Application, the Driver will apply for resources from the cluster manager, then start the Executor process that executes the Application, and send the application code and files to the Executor, and then the Executor will execute the Task.
     - After the operation is completed, the execution result will be returned to the Driver
     - Action -> Job -> Job Stages -> Tasks
       - whenever you invoke an action, the SparkContext creates a job and runs the job scheduler to divide it into stages-->pipelineable
       - tasks are created for every job stage and scheduled to the executors.
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/Jobs%2C%20stages%2C%20tasks.png" width="600" height="300"/>
   - Dependencies between RDDs
     - [38-42](http://debussy.im.nuu.edu.tw/sjchen/BigData/Spark.pdf)
   
   - what is RDD
      - In Spark, datasets are represented as a list of entries, where the list is broken up into many different partitions that are each stored on a different machine. Each partition holds a unique subset of the entries in the list. Spark calls datasets that it stores "Resilient Distributed Datasets" (RDDs).
      - 在Spark，所有的處理和計算任務都會被組織成一系列Resilient Distributed Dataset(彈性分布式數據集，簡稱RDD)上的transformations(轉換) 和 actions(動作)。
      - One of the defining features of Spark, compared to other data analytics frameworks (e.g., Hadoop), is that it stores data in memory rather than on disk. This allows Spark applications to run much more quickly, because they are not slowed down by needing to read data from disk.
      
       <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/rdd_partition.png" width="550" height="400"/>

    - RDD 其他特性
      - immutable: 每個RDD都是不能被改變的，想要更新的？只能從既有中再建立另一個
      - 彈性(Resilient)：如果某節點機器故障，儲存於節點上的RDD損毀，能重新執行一連串的「轉換」指令，產生新的輸出資料
        - 假設我們對RDD做了一系列轉換，例如： line -> badLines -> OtherRDD1 -> OtherRDD2 -> ...，因為每個RDD都是immutable，也就是說，只要紀錄了操作與建立行為(有點類似DB的commit log)，bsdLines RDD就可以從lines RDD取得，所以假設存放badLines RDD的節點損毀了(一或多台)，但只要儲存line RDD的節點還在的話，就能還原badLines了
      
    - ❗❗❗ RDD操作
       - transformation: 操作一個或多個RDD，並產生出新的RDD
       - action(行動類操作)：將操作結果回傳給Driver,或是對RDD元素執行一些操作，但不會產生新的RDD
       - RDD透過運算可以得出新的RDD，但Spark會延遲這個「轉換」動作的發生時間點。它並不會馬上執行，而是等到執行了Action之後，才會基於所有的RDD關係來執行轉換。ex: .collect()
       - Spark’s RDDs are by default recomputed each time you run an action on them. Now the reason behind it is that if it store all the RDDs content in memory then your memory would get exhausted very soon. So, it cannot keep each and every RDDs in memory.When you perform any action on it, it reads from the source data and performs transformations on it and give you the output for your action.However,you can persist the specific RDD using df.cache() or df.persist() and then it will store that RDD content in memory and when you perform any action second time of the RDD that depends upon the cached RDD then it won't read that from the source but it would use it from memory. 
       - You only should cache the RDD if you are **performing multiple actions on it** or **there is a complex transformation logic that you don't want spark to perform every time an action is called**.
     - code example
       ``` python
       a = sc.textFile(filename) 
       b = a.filter(lambda x: len(x)>0 and x.split("\t").count("111"))
       c = b.collect()
       ``` 
       (1) variable a will be saved as a RDD variable containing the expected txt file content</br>
       ❗❗❗ Not really. The line just **describes** what will happen **after** you execute an action, i.e. the RDD variable does **not** contain the expected txt file content.</br>
       (2) The driver node breaks up the work into tasks and each task contains information about the split of the data it will operate on. Now these Tasks are assigned to worker nodes.</br>
       (3) when collection action (i.e collect() in our case) is invoked, the results will be returned to the master from different nodes, and saved as a local variable c.
  - pyspark 用法筆記
     - 常見指令
     
       <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/%E5%B8%B8%E8%A6%8Bspark%20%E6%8C%87%E4%BB%A4.png" width="800" height="550"/>
     - group by key v.s. reduce by key
       - reduceByKey(fun):將具有相同key的key value pair之所有值做合併(Merge)計算
    
         <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/reduce_by_key.png" width="450" height="400"/>
       - groupByKey():以key進行分組，具有相同key的元素之values會形成一個value list (數值串列，或稱Iterable)
       
         <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/groupby_key.png" width="400" height="400"/>      
     - Broadcast Variables
       - Keep read-only variable cached on workers(Ship to each worker only once instead of with each task)
       - Like sending a large, read-only lookup table to all the nodes
       
       <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/Pyspark%20broadcast.png" width="850" height="500"/>
       
       [[Spark內核] 第42課：Spark Broadcast內幕解密：Broadcast運行機制徹底解密、Broadcast源碼解析、Broadcast最佳實踐 ](https://www.cnblogs.com/jcchoiling/p/6538780.html)
     - pyspark 的 Accumulators
       - Accumulators are variables that are used for aggregating information across the executors，for example, the following code can count empty lines during the workers rununing the action
       ``` python
       file = sc.textFile(inputFile)
       blankLines = sc.accumulator(0)
       def extractCallSigns(line):
           global blankLines #	Make the global	variable accessible
           if (line ==""):
	         blankLines+=1
	       return line.split(" ")	
       callSigns = file.flatMap(extractCallSigns)
       print("Blank lines: %d"	% blankLines.value)	
       ``` 
       - Worker tasks on a Spark cluster can add values to an Accumulator with the += operator, but only the driver program is allowed to access its value, using value.(只有driver能獲取Accumulator的值(調用value方法), Task只能對其做增加操作)
     - rdd foreach
       - [difference between rdd foreach and rdd map](https://stackoverflow.com/questions/41388597/difference-between-rdd-foreach-and-rdd-map)
     - pyspark 的join
     
       ``` python
       X.join(Y)
       x=sc.parallelize([("a",1),("b",4)])	
       y=sc.parallelize([("a",2),("a",3)])	
       sorted(x.join(y).collect())	
       Value:	[('a',(1,2)),	('a',(1,3))]
       
       X.leftOuterJoin(Y)
       x=sc.parallelize([("a",1),("b",4)])	
       y=sc.parallelize([("a",2)])	
       sorted(x.leftOuterJoin(y).collect())	
       Value:	[('a',(1,2)),('b',(4,None))]
       
       X.fullOuterJoin(Y)
       x=sc.parallelize([("a",1),("b",4)])	
       y=sc.parallelize([("a",2),("c",8)])	
       sorted(x.fullOuterJoin(y).collect())	
       Value:	[('a',(1,2)),('b',(4,None)),('c',(None,8))]
       ``` 
- pyspark SQL
  - [The Most Complete Guide to pySpark DataFrames](https://towardsdatascience.com/the-most-complete-guide-to-pyspark-dataframes-2702c343b2e8)
  - [9 most useful functions for PySpark DataFrame](https://www.analyticsvidhya.com/blog/2021/05/9-most-useful-functions-for-pyspark-dataframe/?fbclid=IwAR00ptznUg4AYJW6lq2-PG3Egc_F21mw1c5zKLOdY6Igi6ZUtUqvemPIm6A)
  - [PySpark and SparkSQL Basics](https://towardsdatascience.com/pyspark-and-sparksql-basics-6cb4bf967e53)
  - [Spark SQL 102 — Aggregations and Window Functions](https://towardsdatascience.com/spark-sql-102-aggregations-and-window-functions-9f829eaa7549)
  - [Higher-Order Functions with Spark 3.1](https://towardsdatascience.com/higher-order-functions-with-spark-3-1-7c6cf591beaa)
  - [pyspark sql code example](https://nbviewer.org/github/popolee0513/Data-engineering-Note/blob/main/pyspark/Pyspark%20SQL.ipynb)
  - [SparkSQL and DataFrame (High Level API) Basics using Pyspark](https://medium.com/analytics-vidhya/sparksql-and-dataframe-high-level-api-basics-using-pyspark-eaba6acf944b)
  
  
- pyspark performance related issue
  - adding checkpoint(pyspark.sql.DataFrame.checkpoint)
    - Returns a checkpointed version of this Dataset. Checkpointing can be used to truncate the logical plan of this DataFrame, which is especially useful in iterative algorithms where the plan may grow exponentially.(When the query plan starts to be huge, the performance decreases dramatically)
    - after checkpointing the data frame, you don't need to recalculate all of the previous transformations applied on the data frame, it is stored on disk forever
    - When I checkpoint dataframe and I reuse it - It autmoatically read the data from the dir that we wrote the files? yes, it should be read automatically
  - Spark’s Skew Problem
    - Sometimes it might happen that a lot of data goes to a single executor since the same key is assigned for a lot of rows in our data and this might even result in OOM error(when doing groupby or join transformation, same key must stay in same partition and some keys may be more frequent or common which leads to the "skew"), the skewd partition will take longer time to process and make overall job execution time more (all other tasks will be just waiting for it to be completed)
    - how to solve
      - **Salting** [data skew in apache spark](https://medium.com/selectfrom/data-skew-in-apache-spark-f5eb194a7e2)
  - Avoid using UDFs
    - When we execute a DataFrame transformation using native or SQL functions, each of those transformations happen inside the JVM itself, which is where the       implementation of the function resides. But if we do the same thing using Python UDFs, something very different happens.
     - First of all, the code cannot be executed in the JVM, it will have to be in the Python Runtime. To make this possible, each row of the DataFrame is serialized, sent to the Python Runtime and returned to the JVM. As you can imagine, it is nothing optimal.
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/avoid_UDF.png" width="600" height="400"/>
     
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[picture source: Avoiding UDFs in Apache Spark](https://blog.damavis.com/en/avoiding-udfs-in-apache-spark/?fbclid=IwAR3qYhj_cCP5ZFdnhbiTN8nbtE_1dhmc02Pt3qNTnarSZZmclDdFMaR7sx8)
  - Use toPandas with pyArrow
    - using pyarrow to efficiently transfer data between JVM and Python processes    
      ```python 
      pip install pyarrow
      spark.conf.set(“spark.sql.execution.arrow.enabled”, “true”)
      ```
  - pyspark bucketing and Partitioning
   
    <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/partition_bucket.jpg" width="500" height="300"/>
 
    - [Best Practices for Bucketing in Spark SQL](https://medium.com/towards-data-science/best-practices-for-bucketing-in-spark-sql-ea9f23f7dd53)
    - [What is the difference between partitioning and bucketing a table in Hive ?](https://stackoverflow.com/questions/19128940/what-is-the-difference-between-partitioning-and-bucketing-a-table-in-hive?fbclid=IwAR0r9bxcdMCbWDArHa55We9hrpwNyED4QVHQ174TF97-e6jALid7OTzXGw4)
      - [Data Partitioning in Spark (PySpark) In-depth Walkthrough](https://kontext.tech/article/296/data-partitioning-in-spark-pyspark-in-depth-walkthrough)
      - Partitioning is used to obtain performance while querying the data. Example: if we are dealing with a large **employee** table and often run queries with WHERE clauses that restrict the results to a particular country or department. If table is PARTITIONED BY country, DEPT then the partitioning structure will look like this</br>
      .../employees/country=ABC/DEPT=XYZ</br>
      If query limits for employee from country=ABC, it will only scan the contents of one directory country=ABC. This can dramatically improve query performance
      - However, if there are too many partitions, lots of small files will put lots of pressure on the name node(name node:each file is an object in name node)
    - bucketing(some notes)
      - If you are joining a big dataframe multiple times throughout your pyspark application then save that table as bucketed tables and read them back in pyspark as dataframe. this way you can avoid multiple shuffles during join as data is already pre-shuffled
      - if you want to use bucket then spark.conf.get("spark.sql.sources.bucketing.enabled") should return True
      - With bucketing, we can shuffle the data in advance and save it in this pre-shuffled state(reduce shuffle during join operation)
      - Bucket for optimized filtering is available in Spark 2.4+.If we use a filter on the field by which the table is bucketed,Spark will scan files only from the corresponding bucket and avoid a scan of the whole table
      - check if the table bucketed: spark.sql("DESCRIBE EXTENDED table_name").show()
      - ❗❗❗ make sure that the columns for joining have same datatype for two tables
      - ❗❗❗ it is ideal to have the same number of buckets on both sides of the tables in the join; however, if tables with different bucket numbers: just use "spark.sql.bucketing.coalesceBucketsInJoin.enabled" to make to tabels have same number of buckets

- pyspark mllib note
 - Feature Hashing
   - Suppose we have 1 million emails as a training set, each email has only a few dozen words on average, but the vocabulary may be hundreds of thousands, the input data created in this way is a high-dimensional sparse matrix, which is not a friendly input for many machine learning algorithms. 
   - Compared with one-hot encoding , there is no need to maintain a variable table in advance(the conversion of new features does not affect the length of the input feature (because it is defined in advance. hash range)
   - Online learning is convenient, and the time and space complexity of model training is reduced
   - Vectors that were originally very sparse may become less sparse after hash feature engineering
   - ❗ Drawback: The interpretability of the feature is lost, and there is no way to find the original feature from the hashed vector


- pyspark streaming 
  - overview
    -  Spark Streaming first takes live input data streams and then divides them into batches. After this, the Spark engine processes those streams and generates the final stream results in batches. 
    
    <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/pyspark-streaming-flow.png" width="650" height="150"/>
  - learning resources
    - [Apache Spark Structured Streaming — First Streaming Example (1 of 6)](https://medium.com/expedia-group-tech/apache-spark-structured-streaming-first-streaming-example-1-of-6-e8f3219748ef)
    - [Apache Spark Structured Streaming — Input Sources (2 of 6)](https://medium.com/expedia-group-tech/apache-spark-structured-streaming-input-sources-2-of-6-6a72f798838c)
    - [Apache Spark Structured Streaming — Output Sinks (3 of 6)](https://medium.com/expedia-group-tech/apache-spark-structured-streaming-output-sinks-3-of-6-ed3247545fbc)
    - [Apache Spark Structured Streaming — Checkpoints and Triggers (4 of 6)](https://medium.com/expedia-group-tech/apache-spark-structured-streaming-checkpoints-and-triggers-4-of-6-b6f15d5cfd8d)
    - [Apache Spark Structured Streaming — Operations (5 of 6)](https://medium.com/expedia-group-tech/apache-spark-structured-streaming-operations-5-of-6-40d907866fa7)
    - [Apache Spark Structured Streaming — Watermarking (6 of 6)](https://medium.com/expedia-group-tech/apache-spark-structured-streaming-watermarking-6-of-6-1187542d779f)
    - [Spark streaming output modes](https://medium.com/analytics-vidhya/spark-streaming-output-modes-600c689b6bf9)
- Kafka
  - useful links
    - [basic concepts of kafka](https://medium.com/@jhansireddy007/basic-concepts-of-kafka-e49e7674585e)
    - [kafka工作原理](https://xstarcd.github.io/wiki/Cloud/kafka_Working_Principles.html?fbclid=IwAR3QQsNggcAnU1o-NVXbfJsYowhYG1TtbpuXrBtbk8Agm2ancpnRONdpXjk)
    - [An Introduction to Kafka Topics and Partitions](https://codingharbour.com/apache-kafka/the-introduction-to-kafka-topics-and-partitions/?fbclid=IwAR02UXesxrQfZblcrtPnbZQnBD5cs58aor7D-GsrHBARF38t7CWFWnz3N60)
  - basic structure:
    - Broker
      - A kafka server is a broker. A cluster consists of multiple brokers. A broker can hold multiple topics
      - ZooKeeper is responsible for the overall management of Kafka cluster. It monitors the Kafka brokers and notifies Kafka if any broker or partition goes down, or if a new broker or partition goes up
     - topic
       - Topic is a stream of messages, you may consider it as table in database
       - the word topic refers to a category name used to store and publish a particular stream of data
     - Partition
       - In order to achieve scalability, a very large topic can be distributed to multiple brokers (ie servers), a topic can be divided into multiple partitions, and each partition is an ordered queue
       - Each message in the partition is assigned an ordered id (offset). Kafka only guarantees that messages are sent to consumers in the order in a partition, and does not guarantee the order of a topic as a whole (between multiple partitions)
       - That is to say, a topic can have multiple partitions in the cluster, so what is the partition strategy? (There are two basic strategies for which partition the message is sent to, one is to use the Key Hash algorithm, the other is to use the Round Robin algorithm)
       - Each of the partitions could have replicas which are the same copy. This is helpful in avoiding single point of partition failure(`fault tolerance`). 
     - Producer: The message producer is the client that sends messages to the kafka broker.
     - Consumer : message consumer, client that fetches messages from kafka broker
     - A producer writes messages to the topic and a consumer reads them from the topic. This way we are decoupling them since the producer can write messages to the topic without waiting for the consumer. The consumer can then consume messages at its own pace. This is known as the **publish-subscribe pattern**
     - Retention of records
       - One thing that separates Kafka from other messaging systems is the fact that the records are not removed from the topic once they are consumed. This allows multiple consumers to consume the same record and it also allows the same consumer to read the records again (and again)
       - Records are removed after a certain period of time. By default, Kafka will retain records in the topic for 7 days. Retention can be configured per topic
       
- Linux v.s. Shell Scripting basic
  - note
    - [wget -O for non-existing save path?](https://stackoverflow.com/questions/11258271/wget-o-for-non-existing-save-path)
  - [簡明 Linux Shell Script 入門教學](https://blog.techbridge.cc/2019/11/15/linux-shell-script-tutorial/)
  - [Parameter indirection](https://riptutorial.com/bash/example/7567/parameter-indirection)
  - Command substitution
    - Command substitution is a feature of the shell, which helps save the output generated by a command in a variable
    - myfoo=$(echo foo) : echo will write foo to standard out and shell will save it by the variable called myfoo
  - $
    - $(variable) : return the value inside the variable name
    - $# : is the number of positional parameters
    - $0 : is the name of the shell or shell script
    - $1, $2, $3, ... are the positional parameters
 - RDBMS
   - [Database Transaction & ACID](https://oldmo860617.medium.com/database-transaction-acid-156a3b75845e)
   - [[極短篇] 資料庫的 ACID 是什麼？](https://lance.coderbridge.io/2021/04/24/short-what-is-acid/)
   - `Normalization example(From CS50 web course)`</br>
     So far, we’ve only been working with one table at a time, but many databases in practice are populated by a number of tables that all relate to each other in some way. In our flights example, let’s imagine we also want to add an airport code to go with the city. The way our table is currently set up, we would have to add two more columns to go with each row. We would also be repeating information, as we would have to write in multiple places that city X is associated with code Y.</br></br><img src="https://github.com/popolee0513/Data-Engineering-Note/blob/main/PIC/like.png" width="500" height="300"/></br></br>
One way we can solve this problem is by deciding to have one table that keeps track of flights, and then another table keeping track of airports. The second table might look something like this</br></br><img src="https://github.com/popolee0513/Data-Engineering-Note/blob/main/PIC/airports.png" width="500" height="300"/><br>
   Now we have a table relating codes and cities, rather than storing an entire city name in our flights table, it will save storage space if we’re able to just save the id of that airport. Therefore, we should rewrite the flights table accordingly. Since we’re using the id column of the airports table to populate origin_id and destination_id, we call those values `Foreign Keys`</br></br><img src="https://github.com/popolee0513/Data-Engineering-Note/blob/main/PIC/flights2.png" width="500" height="300"/><br>
   - SQL
     - [6 Key Concepts, to Master Window Functions](https://www.startdataengineering.com/post/6-concepts-to-clearly-understand-window-functions/)
     
 - NoSQL
   - the benefits of using NOSQL
     - high scalability 
       - ability to scale horizontally(The elasticity of scaling both up and down to meet the varying demands of applications is key)
       
         <img src="https://github.com/popolee0513/Data-Engineering-Note/blob/main/PIC/horizontal_scaling.jpg" width="500" height="300"/>
       - NoSQL databases are well suited to meet the large data size and **huge number of concurrent users**
     - high performance
        - The need to deliver fast response times even with large data sets and high concurrency is a must for modern applications, and the ability of NoSQL databases to leverage the resources of **large clusters of servers** makes them ideal for fast performance in these circumstances
      - high availability
        - Having a database run on a cluster of servers with **multiple copies** of the data makes for a more resilient solution than a single server solution  
      - flexible schema
        - NoSQL databases also have varied data structures which often are more useful for solving development needs than the rows and columns of relational datastores 
            
	        <img src="https://github.com/popolee0513/Data-Engineering-Note/blob/main/PIC/nosql-database-matrix.png" width="350" height="300"/>
   
   - NoSQL Database Categories (the note is mostly from Coursera IBM Data Engineering course)
      - useful link:  [NoSQL入門介紹及主要類型資料庫說明](https://www.tpisoftware.com/tpu/articleDetails/2016?fbclid=IwAR2Acu_Fs9PIasiX6G9pD8KVwiZRXDWy8NzJ_LJruB-MSc04LOoCj8X2Jyw)
      - document-based(mongoDB)
        - Architecture
          - Values are visible and can be queried
          - Each piece of data is considered as a document(json/xml)
          - Each document is allowed to has it own schema(=>flexible)
          - Contents of document database can be queried and indexed 
          - Can Scale Horizontally
          - Shard easily
        - use case
          - Suitable Situation :
            - event logging for apps(each event can be viewed as a document)
            - Online blogs  - each user, post, comment, like or action is represented by a document
           - Not Suitable Situation:
             - `when you require ACID transactions`
             - if you find yourself forcing your data into an aggregate-oriented design
      - Graph Oriented Database
        - graph databases store information in entities (or nodes), and relationships (or edges). Graph databases are impressive when your data set resembles a graph-like data structure
        - these databases tend not to scale as well horizontally. Sharding a graph database is not recommended
        - Graph databases are also ACID transaction compliant, very much unlike the other NoSQL databases
        - suitable for highly connected data
          - Social networking sites, spatial, and map applications, recommendation engines
      - Column-based(Cassandra)
        - these databases focus on columns and groups of columns when storing and accessing data
        - fast search speed, strong scalability, low complexity
        - use case
          - Suitable Situation :
            - applications with potentially large amounts of data, as large as hundreds of terabytes of data
            - applications with dynamic fields
            - applications that can tolerate short-term inconsistencies in replicas
          - Not Suitable Situation : `when you require ACID transactions`
      - Key-Value <key, value>
        - Architecture 
          - Shard easily
          - Scale well
          - `Ideal for CRUD(create,read,update,delete) operation`
          - Least complex   
          - Not intended for complex queries
          - Value blobs are opaque to database
        - use case
            - Suitable Situation : Anytime you need quick performance for basic Create-Read-Update-Delete operations and `your data is not interconnected`
              - storing and retrieving session information for a Web application
              - storing in-app user-profile and preference
            - Not Suitable Situation: When your data is interconnected with a number of many-to-many relationships in the data
              - social networking or recommendation engine
              - `when you require ACID transactions`
              - if you expect the need to query based on value versus key, it may be wise to consider the `Document category of NoSQL databases`
   - CAP Theorem for NOSQL         
     - [CAP定理101—分散式系統，有一好沒兩好](https://medium.com/%E5%BE%8C%E7%AB%AF%E6%96%B0%E6%89%8B%E6%9D%91/cap%E5%AE%9A%E7%90%86101-3fdd10e0b9a)
     - [技術觀念 | CAP Theorem(CAP定理)](https://morosedog.gitlab.io/technology-20200224-tech-1/?fbclid=IwAR3vljqqBsD6feRfvnP9Y9f5E-g5aXlVWHwUTyyV5IeviPInxvOfKvmMAc0)
  
   - Cassandra
     - use case
       - the use cases where you need to `record some data extremely rapidly` and `make it available immediately for read operations`, and all the while hundreds of thousands of requests are generated
       - limitation
         - dose not support join  ➡➡ use spark
         - limited aggregations support ➡➡ use spark
         - limited support of transactions 
     - basic architecture
       - A Cassandra cluster is a collection of instances, called nodes
       - favors availability over consistency
       - `peer-to-peer architecture`
          - The nodes communicate through a protocol called `gosssip` and they use this transfer information(ex: the status of the node) to one another. 
          - All the nodes in a cluster play the same role
          - There is no master node and every node can perform all database operations and each can serve client requests
          - `The node that first receives a request from a client is the coordinator.` It is the job of the coordinator to forward the request to the nodes holding the data for that request and to send the results back to the coordinator. Any node in the cluster can act as a coordinator.  
      - CQL
        - useful resources
          - [Cassandra權威指南,3rd - Data Modeling筆記](https://zhuanlan.zhihu.com/p/149969643?fbclid=IwAR1H0-UukcbwtvrOgJoizgf0lrm0nw5ujMMzOOS21XbrpEyLBua5L-b5Ajg)
        - QUERY FIRST DESIGN :  In Cassandra, we will first design the storage method of data according to our data retrieval requirements(`design the data model from your query requirements`)(`針對會用到的query 需求設計一個個table`)
        - A key goal when designing tables with Cassandra is that we need to minimize the number of partitions we need to search for a query . Because in Cassandra, the data of one of our partitions is a storage unit that cannot span nodes. A query that only needs to query data on one node tends to perform optimally . ➡➡ 想想從一個node取資料 v.s. 從很多nodes撈取資料所耗費時間
        - Sorting is handled a little differently in Cassandra; it's a design consideration. The sorting method of the results of a query is fixed, and it is completely determined when the table is created clustering columns. `CQL syntax does not support ORDER BY` , only supports ascending or descending order Clustering Columnsto decide .
          
 
