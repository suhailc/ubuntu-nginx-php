#!/bin/bash

supported_dist="Ubuntu"
supported_vers="12.04"

working_dirs=( /var/www/public/ /var/www/private/ /etc/cron.d/ /etc/php5/ /etc/nginx/ )
files_tmp="files/var/tmp/c4-bootstrap-php"
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

function suck_files {
    for var in "${working_dirs[@]}"
    do
        if [[ -d ${var} ]]
        then
            echo "### Pulling in content from ${var} ###"
            if [[ ${var} == "/var/www/public/" ]]
            then
                sudo tar cvfz ${files_tmp}/SiteContent.tgz /var/www/public/*
            elif [[ ${var} == "/var/www/private/" ]]
            then
                sudo tar cvfz ${files_tmp}/ENV.tgz /var/www/private/*
            else
                echo moo
                sudo cp -Rfp ${var} files${var}
            fi
        else
            echo "### WARNING: Directory does not exist! ###"
        fi
    done
}

check_env
suck_files
git_upload
