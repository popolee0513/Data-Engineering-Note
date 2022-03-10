# Data-engineering-Note

- Useful link
  - Data engineering basic idea
    - [資料科學家為何需要了解資料工程](https://leemeng.tw/why-you-need-to-learn-data-engineering-as-a-data-scientist.html)
  - Airflow
    - [一段 Airflow 與資料工程的故事：談如何用 Python 追漫畫連載](https://leemeng.tw/a-story-about-airflow-and-data-engineering-using-how-to-use-python-to-catch-up-with-latest-comics-as-an-example.html)
- pyspark streaming 
  - overview
    - Spark Streaming receives live input data streams, it ** collects data for some time, builds RDD **, divides the data into micro-batches, which are then processed by the Spark engine to generate the final stream of results in micro-batches. Following data flow diagram explains the working of Spark streaming. 
    
    <img src="https://github.com/popolee0513/Data-engineering-Note/blob/main/PIC/pyspark-streaming-flow.png" width="600" height="150"/>
