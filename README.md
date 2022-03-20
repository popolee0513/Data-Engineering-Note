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
     - [Apache Spark Discretized Streams (DStreams) with Pyspark](https://medium.com/analytics-vidhya/apache-spark-discretized-streams-dstreams-with-pyspark-4882026b4fa4)
     - [《巨量資料技術與應用-Spark (Python篇)》實務操作講義- RDD運作基礎](http://debussy.im.nuu.edu.tw/sjchen/BigData-Spark/%E5%B7%A8%E9%87%8F%E8%B3%87%E6%96%99%E6%8A%80%E8%A1%93%E8%88%87%E6%87%89%E7%94%A8%E6%93%8D%E4%BD%9C%E8%AC%9B%E7%BE%A9-RDD%E9%81%8B%E4%BD%9C%E5%9F%BA%E7%A4%8E.html)
     - [4 万字！PySpark 入门级学习教程来了！](https://zhuanlan.zhihu.com/p/436113747)
     - [Spark簡介](http://debussy.im.nuu.edu.tw/sjchen/BigData/Spark.pdf)
- pyspark
  - overview
    - Spark包含1個driver和若干個exexutor（在各個節點上）(master-slave architecture, the master is the driver, and slaves are the executors.)
    - Driver會把計算任務分成一系列小的task，然後送到executor執行。executor之間可以通信，在每個executor完成自己的task以後，所有的信息會被傳回。
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/spark_structure.png" width="500" height="300"/>
   - spark basic architecture
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/pyspark%E6%9E%B6%E6%A7%8B.png" width="900" height="500"/>
     
     1. After submitting the job through SparkSubmit, the Client starts to build the spark context, that is, the execution environment of the application
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
     - After the operation is completed, the execution result will be returned to the Driver</br>
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/Jobs%2C%20stages%2C%20tasks.png" width="600" height="300"/>
     
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
       
- pyspark streaming 
  - overview
    -  Spark Streaming first takes live input data streams and then divides them into batches. After this, the Spark engine processes those streams and generates the final stream results in batches. 
    
    <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/pyspark-streaming-flow.png" width="650" height="150"/>
