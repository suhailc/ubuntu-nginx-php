#!/bin/bash

supported_dist="Ubuntu"
supported_vers="10.04"
prod=1

function check_env {
    distro=`lsb_release -i | awk -F " " '{ print $3 }'`
    version=`lsb_release -r | awk -F " " '{ print $2 }'`
    echo "### Checking System ###"
    if [[ -n ${version} && ${version} == ${supported_vers} && ${distro} == ${supported_dist} ]]
    then
        echo "${distro} ${version} matches supported versions"
        echo "### DONE ###"
    else
        echo "### ERROR: System not Supported you need to be running ${supported_dist} ${supported_vers} ###"
        exit 0
    fi    
}

function explode_files {
    echo "### Exploding files onto system ###"
    if [ ${prod} -eq 1 ]
    then
        echo "### PROD System Used ###"
        cp -Rf files/* /
    else
        echo "### NON PROD System Using /tmp/bootstrap ###"
        mkdir /tmp/bootstrap
        cp -Rf files/* /tmp/bootstrap/
    fi
    echo "### DONE ###"
}

function run_scripts {
    echo "### Running $1 scripts ###"
    for i in `ls scripts/$1` ;
    do 
        echo "### Running $i ###"
        sudo /bin/bash scripts/$1/$i ; 
    done
    echo "### DONE ###"
}

check_env
run_scripts pre.d
explode_files
run_scripts post.d
