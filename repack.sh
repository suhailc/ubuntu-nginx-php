#!/bin/bash

supported_dist="Ubuntu"
supported_vers="10.04"

timestamp=`date --utc +%s`

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

function git_upload {
    read -p "write 'Have you updated your Git Repo settings' (y/N)? "
    if [[ "$REPLY" == "y" || "$REPLY" == "Y" ]]
    then
        echo "### Prepreping Git for upload ###"
        echo "git add *"
        git commit -m "${timestamp}"
        git push
    else
        echo "### ERROR: Failed to upload to Git ###"
        exit 0
    fi    
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
run_scripts repack
git_upload
