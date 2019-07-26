# ENMA - Documentation for developers

[Return home](../README.md)

## 1. General information

**Standard workflow**

The standard workflow, used by the modules developed until now, is explained in the [module workflow section](../modules/workflow.md).

This `Documentation for developers` section is made exclusively for developers who needs to adapt or create a new module in the platform.

**Template project**

[A project template to work with ENMA can be found in this github](https://github.com/BeeGroup-cimne/project_template).

This project contains all the files to create modules to work with the architecture in an easy way.

The configuration of the project is explained in the template github documentation. To develop each data analysis module, take into account the following steeps.

1. Each data analysis module should be in a folder(copy of `_module_template`)
2. Fill the `module_vaiables.sh` file with the correct values
3. Use the requirements.txt file to add all needed packages for the executions
4. `task.py` contains the basic task script. It should contain wether a subclass of `BeeModule2` or `BeeModule3` to work with `python2` or `python3` respectively.

The following is the folder structure of a data analysis project.

      (root)
        |
        |
        +-- .modules_config_files(hidden folder that contains information on how to install the modules into the ENMA)
        +-- config.json (General configuration of the project)
        +-- _module_template(folder that contains a blank module for developers)
        +-- general_variables.sh (config_variables for this project)
        +-- install.sh (Install scrip for all modules of this project)
        +-- module_python2.py (base class for python2)
        +-- module_python3.py (base class for python3)
        +-- module1 (one data module)
        |    +-- task.py (executable of ths task)
        |    +-- requirements.txt (requirements of this module)
        |    +-- module_variables.sh (environment variables of this module)
        |    +-- install.sh (installation script for this module)
        |    +-- config.json (configuration of this module)
        |    +-- Other required files depending on the work.

**Configurate the call to MRJob**

When calling a `MRJob from the `task.py` we can use a set of parameters available in the MRJob package.

```python
MRJob(
    args=['-r', 'hadoop', 'hdfs://' + input_data, '--file', config_file, '-c', 'mrjob.conf',
                    '--output-dir', 'hdfs://' + output_file,
                    '--jobconf])
```

More parameters that can be useful can be found in the [MRJob documentation](https://pythonhosted.org/mrjob/)

In this modules, all files and folders inside the module will be uploaded in the working directory of Hadoop, this means that the developers are free to import all of them in the MRJob.
```python
from folder.file import class_in_file
```
However if we want to share a folder with code between different modules, we have to specify it into the MRJob call, using the flag

```python
--dir project/_shared_folder#_shared_folder_in_hadoop'
```
then we can import this code in the MRJob with:

```python
from project/shared_folder_in_hadoop/file import class_in_file
```


**Iniciate the celery process**

Before the execution of the modules, the celery process has to be started with this shell sentence:
```bash

     cd /home/empowering/<developer_user>
     celery worker --app=celery_backend:app -l debug
```
When Celery is started, this process awaits to queue and launch new module executions. In the moment when a module is launched, all the logs that will produce, will be printed on the Celery screen. This logs are very helpful for the module developer to know if the execution is working properly or if it crashes in some subtask.


**Launch from a Python console**

To launch a module from a Python console, follow these steps:

1. Open a Python console from the shell

```bash

    cd /home/empowering/<developer_user>
    python
```

2. Import the module function (In this example, module ot000 and measures ETL functions are loaded).

```python

   from project.tasks import module
```

3. Create the *params* dictionary. This variable defines the input parameters of the module. (In this example, an example params of module ot101 is shown)

```python

    params = {
            'key': 'value'
            }
```
4. Launch the module (In this example, module ot000 is launched)

```python

    result = module.delay(params)
```

**Documentation of Projects**

For each different project, the documentation will be found in it's github page.