# Data-engineering-Note

- Useful link
  - Data engineering basic idea
    - [資料科學家為何需要了解資料工程](https://leemeng.tw/why-you-need-to-learn-data-engineering-as-a-data-scientist.html)
  - Airflow
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
    - overall
          
      <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/partition_bucket.jpg" width="500" height="300"/>
      
      - PARTITIONING
        - Partitioning is used to obtain performance while querying the data. For example, in the above table, if we write the below sql, it need to scan all the records in the table which reduces the performance and increases the overhead.</br>
        ```python 
        ../sales_table/product_id=P1
        ../sales_table/product_id=P2
	```
	</br>
        - To avoid full table scan and to read only the records related to product_id='P1' we can partition (split table files) into multiple files based on the product_id column. 
        - By this the table's file will be split into two files one with product_id='P1' and other with product_id='P2'. Now when we execute the above query, it will scan only the product_id='P1' file.
        - We should be very careful while partitioning. That is, it should not be used for the columns where number of repeating values are very less (especially primary key columns) as it increases the number of partitioned files and increases the overhead.(it must keep all metadata for the file system in memory)
    - bucketing 
      - Bucketing should be used when there are very few repeating values in a column (example - primary key column). This is similar to the concept of index on primary key column in the RDBMS. In our table, we can take Sales_Id column for bucketing. It will be useful when we need to query the sales_id column.
      - Here we will further split the data into few more files on top of partitions.Since we have specified 3 buckets, it is split into 3 files each for each product_id</br>
        ```sql
        ..sales_table/product_id=P1/000000_0
        ..sales_table/product_id=P1/000001_0
        ..sales_table/product_id=P1/000002_0
        ..sales_table/product_id=P2/000000_0
        ..sales_table/product_id=P2/000001_0
        ..sales_table/product_id=P2/000002_0
        ```

- pyspark streaming 
  - overview
    -  Spark Streaming first takes live input data streams and then divides them into batches. After this, the Spark engine processes those streams and generates the final stream results in batches. 
    
    <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/pyspark-streaming-flow.png" width="650" height="150"/>
