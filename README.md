# Data-engineering-Note

- Useful link
  - Data engineering basic idea
    - [資料科學家為何需要了解資料工程](https://leemeng.tw/why-you-need-to-learn-data-engineering-as-a-data-scientist.html)
  - Airflow
    - [一段 Airflow 與資料工程的故事：談如何用 Python 追漫畫連載](https://leemeng.tw/a-story-about-airflow-and-data-engineering-using-how-to-use-python-to-catch-up-with-latest-comics-as-an-example.html)
   - Amazon Kinesis
     - [利用 Kinesis 處理串流資料並建立資料湖](https://leemeng.tw/use-kinesis-streams-and-firehose-to-build-a-data-lake.html)
     - 可以把Kinesis Data Stream裡的shards想成港口，港口越多吞吐量越大，而Firehose delivery stream則是把貨物(資料)運送到目的地的船隻
    - [Apache Spark Discretized Streams (DStreams) with Pyspark](https://medium.com/analytics-vidhya/apache-spark-discretized-streams-dstreams-with-pyspark-4882026b4fa4)
- pyspark
  - overview
    - Spark包含1個driver和若干個exexutor（在各個節點上）
    - Driver會把計算任務分成一系列小的task，然後送到executor執行。executor之間可以通信，在每個executor完成自己的task以後，所有的信息會被傳回。
     
     <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/spark_structure.png" width="500" height="300"/>
     
    - 在Spark，所有的處理和計算任務都會被組織成一系列Resilient Distributed Dataset(彈性分布式數據集，簡稱RDD)上的transformations(轉換) 和 actions(動作)。
    - what is RDD
      - In Spark, datasets are represented as a list of entries, where the list is broken up into many different partitions that are each stored on a different machine. Each partition holds a unique subset of the entries in the list. Spark calls datasets that it stores "Resilient Distributed Datasets" (RDDs).
      - One of the defining features of Spark, compared to other data analytics frameworks (e.g., Hadoop), is that it stores data in memory rather than on disk. This allows Spark applications to run much more quickly, because they are not slowed down by needing to read data from disk.
      
       <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/rdd_partition.png" width="550" height="400"/>

    - RDD 其他特性
      - immutable: 每個RDD都是不能被改變的，想要更新的？只能從既有中再建立另一個
      - 彈性(Resilient)：如果某節點機器故障，儲存於節點上的RDD損毀，能重新執行一連串的「轉換」指令，產生新的輸出資料
        - 假設我們對RDD做了一系列轉換，例如： line -> badLines -> OtherRDD1 -> OtherRDD2 -> ...，因為每個RDD都是immutable，也就是說，只要紀錄了操作與建立行為(有點類似DB的commit log)，bsdLines RDD就可以從lines RDD取得，所以假設存放badLines RDD的節點損毀了(一或多台)，但只要儲存line RDD的節點還在的話，就能還原badLines了
      
    - RDD操作
       - transformation: 操作一個或多個RDD，並產生出新的RDD
       - action(行動類操作)：將操作結果回傳給Driver,或是對RDD元素執行一些操作，但不會產生新的RDD
       - ❗❗❗ RDD透過運算可以得出新的RDD，但Spark會延遲這個「轉換」動作的發生時間點。它並不會馬上執行，而是等到執行了Action之後，才會基於所有的RDD關係來執行轉換。ex: .collect()
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
- pyspark streaming 
  - overview
    -  Spark Streaming first takes live input data streams and then divides them into batches. After this, the Spark engine processes those streams and generates the final stream results in batches. 
    
    <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/pyspark-streaming-flow.png" width="650" height="150"/>
