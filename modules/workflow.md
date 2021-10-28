# ENMA - Analytical modules workflow

[Return home](../README.md)

## 1. General description of the structure of a ENMA task

The module workflow must be implemented in a docker container, this container migth need all the required dependencies to run
in the application. One of the best aproaches is to make the container run a commander scripts that orchestrates all the different
steps of the module. This script defines the module function and his subtasks workflow, which are executed in a synchronously way.

In the following schema, the general structure is shown.

![ENMA Architecture](../pictures/modules_general_structure.png)

In general, the most common subtasks are HIVE queries, R scripts or Python scripts. In the next paragraphs, a brief description of each of them is made.

**HIVE queries**

HIVE is used as to access and query the data warehouse in a language similar to SQL (HiveQL), the raw or pretreated data stored in HBase or HDFS. The HIVE results generated are saved always as text files in the HDFS. In order to reduce at maximum the input dimensionality on subsequent subtasks, some basic calculations of the initial data are usually made in this queries (e.g. aggregations, products, counts, average calculations).

**R scripts**

This software is broadly used by data scientists to make sense of data using statistics or machine learning algorithms. This allows the developers to use all the existing R functions in a big data environment.
**Python scripts**

Python is broadly used by data scientists. There exists plenty of data mining libraries such as Numpy, Pandas or Scipy. This type of subtask is also very useful to read and write to MongoDB or HBase.

**Others**

The subtasks descriebed above are the among the most common in the developement of moules, however, the developer can decide to use other technologies by creating a valid docker for the platform.
