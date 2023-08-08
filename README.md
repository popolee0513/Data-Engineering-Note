# Data-engineering-Note
 
- Useful link
  - Data engineering basic idea
    - [資料科學家為何需要了解資料工程](https://leemeng.tw/why-you-need-to-learn-data-engineering-as-a-data-scientist.html)
  - Amazon Kinesis
     - [利用 Kinesis 處理串流資料並建立資料湖](https://leemeng.tw/use-kinesis-streams-and-firehose-to-build-a-data-lake.html)
     - 可以把Kinesis Data Stream裡的shards想成港口，港口越多吞吐量越大，而Firehose delivery stream則是把貨物(資料)運送到目的地的船隻
  - Airflow
     - [How to aggregate data for BigQuery using Apache Airflow](https://cloud.google.com/blog/products/bigquery/how-to-aggregate-data-for-bigquery-using-apache-airflow)
     - [一段 Airflow 與資料工程的故事：談如何用 Python 追漫畫連載](https://leemeng.tw/a-story-about-airflow-and-data-engineering-using-how-to-use-python-to-catch-up-with-latest-comics-as-an-example.html)
     - [Data lake with Pyspark through Dataproc GCP using Airflow](https://ilhamaulanap.medium.com/data-lake-with-pyspark-through-dataproc-gcp-using-airflow-d3d6517f8168)
     - Note:
       - Airflow BigQueryOperator: how to save query result in a partitioned Table?
         
         ```sql
         bq_cmd = BigQueryOperator (
            task_id= "task_id",
            sql= [query],
            destination_dataset_table= destination_tbl,
            use_legacy_sql= False,
            write_disposition= 'WRITE_TRUNCATE',
            time_partitioning= {'time_partitioning_type':'DAY'},
            allow_large_results= True,
            dag= dag)
         ```
       - get the metadata of the tables or check if the table exists or not
       
         ```sql
         -- Returns metadata for tables in a single dataset.
         SELECT * FROM myDataset.INFORMATION_SCHEMA.TABLES;
         ```
  - Pyspark
     - [巨量資料技術與應用-Spark (Python篇) 實務操作講義- RDD運作基礎](http://debussy.im.nuu.edu.tw/sjchen/BigData-Spark/%E5%B7%A8%E9%87%8F%E8%B3%87%E6%96%99%E6%8A%80%E8%A1%93%E8%88%87%E6%87%89%E7%94%A8%E6%93%8D%E4%BD%9C%E8%AC%9B%E7%BE%A9-RDD%E9%81%8B%E4%BD%9C%E5%9F%BA%E7%A4%8E.html)
     - [PySpark Tutorial](https://sparkbyexamples.com/)
     - [Pyspark API reference](https://spark.apache.org/docs/latest/api/python/reference/index.html)
     - [Spark簡介](http://debussy.im.nuu.edu.tw/sjchen/BigData/Spark.pdf)
     - **⭐⭐⭐[Apache Spark Performance Boosting](https://towardsdatascience.com/apache-spark-performance-boosting-e072a3ec1179)**
- Bigquery: can provide a large amount of data storage, and query your stored data in the form of structured query (SQL), and can support the Join action between data tables.
  - Link
    - [Save the result of a query in a BigQuery Table, in Cloud Storage](https://stackoverflow.com/questions/72103557/save-the-result-of-a-query-in-a-bigquery-table-in-cloud-storage)
  - Note
    - BigQuery supports a few external data sources: you may query these sources directly from BigQuery even though the data itself isn't stored in BQ. An **external table** is a table that acts like a standard BQ table. The table metadata (such as the schema) is stored in BQ storage but the data itself is external and **BQ will figure out the table schema and the datatypes based on the contents of the files.**(Be aware that BQ cannot determine processing costs of external tables.)</br>
      📑 Common metadata : </br>
      •	table definition (what are the columns, eg: sale_id)</br>
      •	The data type of each column</br>
      •	The order in which each column actually appears in the original data</br>
   - Tip
     - Optimize your join patterns Best practice: For queries that join data from multiple tables, start with the largest table.
     - Use external data sources appropiately. Constantly reading data from a bucket may incur in additional costs and has worse performance.
     - **Use clustered and/or partitioned tables if possible.**
     - Avoid select* (BigQuery engine utilizes columnar storage format to scan only the required columns to run the query. One of the best practices to control costs is to query only the columns that you need.)


- pyspark
  - overview
    - Spark includes driver and multiple workers（on different node）(master-slave architecture, the master is the driver, and slaves are the workers)
    - Spark clusters(often contain multiple computers) are managed by a `master`. A driver that wants to execute a Spark job will send the job to the master, which in turn will divide the work among the cluster's workers. If any worker fails and becomes offline for any reason, the master will reassign the task to another worker.
    
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/spark_structure.png" width="500" height="300"/>
  - Spark Cluster Topology
  
     <img src="https://github.com/popolee0513/Data-Engineering-Note/blob/main/PIC/spark-cluster-topology.png" width="400" height="350"/>
      Very Short Summary: Driver (submits) -> Master (manages) -> Worker/Executor (pull data and process it)
      In Spark Cluster, there are number of executors and each executor process one file at a time. If we have one big file, then the file can be handled by only one 
      executor and the rest of executors stay in idle state.

Therefore, it is important to understand best practices for to distribute workload in different executors. This is possible by partitioning.
  
  - Jobs, stages, tasks
     - An Application consists of a Driver and several Jobs, and a Job consists of multiple Stages
     - When executing an Application, the Driver will apply for resources from the cluster manager, then start the Executor process that executes the Application, and send the application code and files to the Executor, and then the Executor will execute the Task
     - After the operation is completed, the execution result will be returned to the Driver
     - Action -> Job -> Job Stages -> Tasks
       - whenever you invoke an action, the SparkContext(Spark的入口，相當於應用程序的main函數) creates a job and runs the job scheduler to divide it into stages-->pipelineable
       - tasks are created for every job stage and scheduled to the executors
     
        <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/Jobs%2C%20stages%2C%20tasks.png" width="350" height="250"/>
   
   - what is RDD
      - In Spark, datasets are represented as a list of entries, where the list is broken up into many different partitions that are each stored on a different machine. Each partition holds a unique subset of the entries in the list. Spark calls datasets that it stores "Resilient Distributed Datasets" (RDDs).
     - RDD 特性
       - `immutable`: 每個RDD都是不能被改變的，想要更新的？只能從既有中再建立另一個
       - `Resilient`：如果某節點機器故障，儲存於節點上的RDD損毀，能重新執行一連串的「轉換」指令，產生新的輸出資料
          假設我們對RDD做了一系列轉換，例如： line ▶ badLines ▶ OtherRDD1 ▶ OtherRDD2 ▶ ...，因為每個RDD都是immutable，也就是說，只要紀錄了操作與建立行為(有點類似log)，badLines RDD就可以從line RDD取得，所以假設存放badLines RDD的節點損毀了(一或多台)，但只要儲存line RDD的節點還在的話，就能還原badLines了
      
    - RDD操作
       - ✅ Transformation：操作一個或多個RDD，並產生出新的RDD
       - ✅ Action(行動類操作)：將操作結果回傳給Driver,或是對RDD元素執行一些操作,但不會產生新的RDD
       - RDD透過運算可以得出新的RDD，但Spark(SQL)會延遲這個「轉換」動作的發生時間點。它並不會馬上執行，而是等到執行了Action之後，才會基於所有的RDD關係來執行轉換。ex: rdd.collect()
   
     - code example
       ``` python
       a = sc.textFile(filename) 
       b = a.filter(lambda x: len(x)>0 and x.split("\t").count("111"))
       c = b.collect()
       ``` 
       (1) variable a will be saved as a RDD variable containing the expected txt file content</br>
       ❗❗❗ Not really. The line just **describes** what will happen `after you execute an action`, i.e. the RDD variable does **not** contain the expected txt file content.</br>
       (2) The driver node breaks up the work into tasks and each task contains information about the split of the data it will operate on. Now these Tasks are assigned to worker nodes.</br>
       (3) when collection **action** (i.e collect() in our case) is invoked, the results will be returned to the master from different nodes, and saved as a local variable c.
  
- pyspark SQL
  - [The Most Complete Guide to pySpark DataFrames](https://mlwhiz.com/blog/2020/06/06/spark_df_complete_guide/)
  - [9 most useful functions for PySpark DataFrame](https://www.analyticsvidhya.com/blog/2021/05/9-most-useful-functions-for-pyspark-dataframe/?fbclid=IwAR00ptznUg4AYJW6lq2-PG3Egc_F21mw1c5zKLOdY6Igi6ZUtUqvemPIm6A)
  - [Spark SQL 102 — Aggregations and Window Functions](https://towardsdatascience.com/spark-sql-102-aggregations-and-window-functions-9f829eaa7549)
  - [Higher-Order Functions with Spark 3.1](https://towardsdatascience.com/higher-order-functions-with-spark-3-1-7c6cf591beaa)
  - [pyspark sql code example](https://nbviewer.org/github/popolee0513/Data-engineering-Note/blob/main/pyspark/Pyspark%20SQL.ipynb)
  - [SparkSQL and DataFrame (High Level API) Basics using Pyspark](https://medium.com/analytics-vidhya/sparksql-and-dataframe-high-level-api-basics-using-pyspark-eaba6acf944b)
  
- pyspark performance related issue
  - `Adding checkpoint(pyspark.sql.DataFrame.checkpoint)`
    - Returns a checkpointed version of this Dataset. Checkpointing can be used to truncate the logical plan of this DataFrame, which is especially useful in iterative algorithms where the plan may grow exponentially.(When the query plan starts to be huge, the performance decreases dramatically)
    - After checkpointing the data frame, you don't need to recalculate all of the previous transformations applied on the dataframe, it is stored on disk forever
    - When I checkpoint dataframe and I reuse it - It autmoatically read the data from the dir that we wrote the files? yes, it should be read automatically
  - `Spark’s Skew Problem`
    - Sometimes it might happen that a lot of data goes to a single executor since the same key is assigned for a lot of rows in our data and this might even result in OOM error(when doing groupby or join transformation, same key must stay in same partition and some keys may be more frequent or common which leads to the `skew`), the skewd partition will take longer time to process and make overall job execution time more (all other tasks will be just waiting for it to be completed)
    - how to solve
      - **Salting** [data skew in apache spark](https://medium.com/selectfrom/data-skew-in-apache-spark-f5eb194a7e2)
  - `Avoid using UDFs`
    - When we execute a DataFrame transformation using native or SQL functions, each of those transformations happen inside the JVM itself, which is where the implementation of the function resides. But if we do the same thing using Python UDFs, something very different happens.
     - First of all, the code cannot be executed in the JVM, it will have to be in the Python Runtime. To make this possible, each row of the DataFrame is serialized, sent to the Python Runtime and returned to the JVM. As you can imagine, it is nothing optimal.
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/avoid_UDF.png" width="600" height="400"/>
     
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[picture source: Avoiding UDFs in Apache Spark](https://blog.damavis.com/en/avoiding-udfs-in-apache-spark/?fbclid=IwAR3qYhj_cCP5ZFdnhbiTN8nbtE_1dhmc02Pt3qNTnarSZZmclDdFMaR7sx8)
  - `Use toPandas with pyArrow`
    - using pyarrow to efficiently transfer data between JVM and Python processes    
      ```python 
      pip install pyarrow
      spark.conf.set("spark.sql.execution.arrow.enabled", "true")
      ```
  - `pyspark bucketing and Partitioning`
   
    <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/partition_bucket.jpg" width="500" height="300"/>
 
    - [Best Practices for Bucketing in Spark SQL](https://medium.com/towards-data-science/best-practices-for-bucketing-in-spark-sql-ea9f23f7dd53)
    - [What is the difference between partitioning and bucketing a table in Hive ?](https://stackoverflow.com/questions/19128940/what-is-the-difference-between-partitioning-and-bucketing-a-table-in-hive?fbclid=IwAR0r9bxcdMCbWDArHa55We9hrpwNyED4QVHQ174TF97-e6jALid7OTzXGw4)
      - [Data Partitioning in Spark (PySpark) In-depth Walkthrough](https://kontext.tech/article/296/data-partitioning-in-spark-pyspark-in-depth-walkthrough)
      - Partitioning is used to obtain performance while querying the data. Example: if we are dealing with a large **employee** table and often run queries with WHERE clauses that restrict the results to a particular country or department. If table is PARTITIONED BY country, DEPT then the partitioning structure will look like this</br>
      .../employees/country=ABC/DEPT=XYZ</br>
      If query limits for employee from country=ABC, it will only scan the contents of one directory country=ABC. This can dramatically improve query performance
      - `However, if there are too many partitions, there will be excessive cost in managing lots of small tasks(Too few partitions You will not utilize all of the cores available in the cluster)`
    - `Bucketing(some notes)`
      - use Hash(x) mod n to assign each data to a bucket
      - If you are joining a big dataframe multiple times throughout your pyspark application then save that table as bucketed tables and read them back in pyspark as dataframe. this way you can avoid multiple shuffles during join as data is already pre-shuffled
      - if you want to use bucket then spark.conf.get("spark.sql.sources.bucketing.enabled") should return True
      - With bucketing, we can shuffle the data in advance and save it in this pre-shuffled state(reduce shuffle during join operation)
      - Bucket for optimized filtering is available in Spark 2.4+. If we use a filter on the field by which the table is bucketed, Spark will scan files only from the corresponding bucket and avoid a scan of the whole table
      - check if the table bucketed: spark.sql("DESCRIBE EXTENDED table_name").show()
      - ❗❗❗ make sure that the columns for joining **have same datatype for two tables**
      - ❗❗❗ it is ideal to **have the same number of buckets** on both sides of the tables in the join; however, if tables with different bucket numbers: just use `spark.sql.bucketing.coalesceBucketsInJoin.enabled` to make to tabels have same number of buckets

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
    - [10 Configs to Make Your Kafka Producer More Resilient](https://towardsdatascience.com/10-configs-to-make-your-kafka-producer-more-resilient-ec6903c63e3f)
    - [basic concepts of kafka](https://medium.com/@jhansireddy007/basic-concepts-of-kafka-e49e7674585e)
    - [An Introduction to Kafka Topics and Partitions](https://codingharbour.com/apache-kafka/the-introduction-to-kafka-topics-and-partitions/?fbclid=IwAR02UXesxrQfZblcrtPnbZQnBD5cs58aor7D-GsrHBARF38t7CWFWnz3N60)
  - basic structure:
    - **Broker**
      - A kafka server is a broker. A cluster consists of multiple brokers. A broker can hold multiple topics
      - ZooKeeper is responsible for the overall management of Kafka cluster. It monitors the Kafka brokers and notifies Kafka if any broker or partition goes down, or if a new broker or partition goes up
     - **Topic**
       - Topic is a stream of messages, you may consider it as table in database
       - the word topic refers to a category name used to store and publish a particular stream of data
     - **Partition**
       - In order to achieve scalability, a very large topic can be distributed to multiple brokers (ie servers), a topic can be divided into multiple partitions, and each partition is an ordered queue
       - Each message in the partition is assigned an ordered id (offset). Kafka only guarantees that messages are sent to consumers in the order in a partition, and does not guarantee the order of a topic as a whole (between multiple partitions)
       - That is to say, a topic can have multiple partitions in the cluster, so what is the partition strategy? There are two basic strategies for which partition the message is sent to, one is to use the Key Hash algorithm, the other is to use the Round Robin algorithm
       - Each of the partitions could have replicas which are the same copy. This is helpful in avoiding single point of partition failure(`fault tolerance`). 
     - **Replication**
       - When a partition is replicated accross multiple brokers, one of the brokers becomes the leader for that specific partition. The leader handles the message and writes it to its partition log. The partition log is then replicated to other brokers, which contain replicas for that partition. Replica partitions should contain the same messages as leader partitions.
       - If a broker which contains a leader partition dies, another broker becomes the leader and picks up where the dead broker left off, thus guaranteeing that both producers and consumers can keep posting and reading messages.
     - **Producer** : The message producer is the client that sends messages to the kafka broker
  
     ```mermaid
    flowchart LR
        p(producer)
        k{{kafka broker}}
        subgraph logs[logs for topic 'abc']
            m1[message 1]
            m2[message 2]
            m3[message 3]
        end
        p-->|1. Declare topic 'abc'|k
        p-->|2. Send messages 1,2,3|k
        k -->|3. Write messages 1,2,3|logs
        k-.->|4. ack|p
    ```
     - **Consumer** : message consumer, client that fetches messages from kafka broker
     
     ```mermaid
    flowchart LR
        c(consumer)
        k{{kafka broker}}
        subgraph logs[logs for topic 'abc']
            m1[message 1]
            m2[message 2]
            m3[message 3]
        end
        c-->|1. Subscribe to topic 'abc|k
        k<-->|2. Check messages|logs
        k-->|3. Send unread messages|c
        c-.->|4. ack|k
    ```
     - A producer writes messages to the topic and a consumer reads them from the topic. This way we are decoupling them since the producer can write messages to the topic without waiting for the consumer. `The consumer can then consume messages at its own pace.` This is known as the **publish-subscribe pattern**
     - Retention of records
       - One thing that separates Kafka from other messaging systems is the fact that the records are not removed from the topic once they are consumed. This allows multiple consumers to consume the same record and it also allows the same consumer to read the records again (and again)
       - Records are removed after a certain period of time. By default, Kafka will retain records in the topic for 7 days. Retention can be configured per topic
     - Note on Config
       - When a producer does not receive an acknowledgement for some time (defined by the property `max.block.ms`), it resends the message (after time defined by the property `retry.backoff.ms`). It keeps resending the failed messages for number of times defined by the property `retries`.
       - `batch.size`, `linger.ms` When these two parameters are set at the same time, as long as one of the two conditions is met, it will be sent. For example, if batch.size is set to 16kb and linger.ms is set to 50ms, then when the messages in the internal buffer reach 16kb, the messages will be sent. If size of total message <16kb, then the first message will be sent after 50ms of its arrival.
  - Schema Registry
    
    <img src="https://github.com/popolee0513/Data-Engineering-Note/blob/main/PIC/Schema%20Registry.png" width="450" height="250"/>
     
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
     
 - Cassandra
   - [Crash Course | Introduction to Cassandra for Developers](https://www.youtube.com/watch?v=jgqu1BcSKUI&ab_channel=DataStaxDevelopers)
 - GCP
   - **GCP Service Account**: the purpose of the Service Account is to `provide the permissions required for the application to execute on GCP.`
 - Difference between a data lake and a data warehouse?
   - Data lake holds data of all structure types, including raw and unprocessed data, a data warehouse stores data that has been treated and transformed with a specific purpose in mind, which can then be used to source analytic or operational reporting. 
          
 
