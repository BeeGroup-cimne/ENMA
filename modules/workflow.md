# ENMA module workflow

[Return home](../README.md)

## 1. General description of the structure of a ENMA task

The module workflow is always commanded by a general Python script which is usually called `tasks.py` and it is located inside the root module folder. This script defines the module function and his subtasks workflow, which are executed in a synchronously way.

In the following schema, the general structure is shown.

![ENMA Architecture](../pictures/modules_general_structure.png)


All the modules are programed in Python. In order to launch the desired modules, these functions have to be added in the Celery task queue. Then, this software execute the different subtasks depending the queue order and the system availability.

In general, all the subtasks are HIVE queries, R scripts or Python scripts. In the next paragraphs, a brief description of each of them is made.

**HIVE queries**

HIVE is used as a data warehouse to access and query, in a language similar to SQL (HiveQL), the raw or pretreated data stored in HBase or HDFS. The HIVE results generated are saved always as text files in the HDFS. In order to reduce at maximum the input dimensionality on subsequent subtasks, some basic calculations of the initial data are usually made in this queries (e.g. aggregations, products, counts, average calculations).


**R scripts**

This software is broadly used by data scientists to make sense of data using statistics or machine learning algorithms. In this platform,  Rhadoop are used to provide a way to use Hadoop from R. This allows the developers to use all the existing R functions in a big data environment. Usually the input data for this scripts comes from text or sequence files stored in HDFS. The output can be also stored in text or sequence files. This type of subtask is always an individual R script which is called from the general Python script.

**Python scripts**

Python is the main language of the platform, all sorts of Python algorithms can be implemented. There are some data mining libraries installed in the system, such as Numpy, Pandas or Scipy, and to provide a way to use Hadoop from Python, MRjob library is installed. This type of subtask is also very useful to read and write to MongoDB or HBase.

**Others**

The subtasks descriebed above are the among the most common in the developement of moules, however, the developer can decide to use other technologies always when they work with the Hadoop and ENMA ecosystem.
