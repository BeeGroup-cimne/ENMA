#! /bin/bash
while read p
    do
        host=`echo $p|cut -d" " -f1`
        name=`echo $p|cut -d" " -f2`
        echo "running on $name"
        ssh -n $host "$2"
           done < $1