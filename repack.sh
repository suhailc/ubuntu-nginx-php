#!/bin/bash

#
#    c4-bootstrap, bootstrap.sh quickly sets up your system based on contents on package
#    Copyright (C) 2012 Richard Harvey<richard@squarecows.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#### Change these values for your system ####

supported_dist="Ubuntu"
supported_vers="10.04"

#############################################

timestamp=`date --utc +%s`

function check_sudo {
   if [ "$(id -u)" != "0" ]; then
       echo "This script requires root.  Try 'sudo ./bootstrap.sh'" 1>&2
       exit 1
   fi
}

function check_env {
    check_sudo
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
    read -p "write 'Do you want to commit and push changes to github? ' (y/N)? "
    if [[ "$REPLY" == "y" || "$REPLY" == "Y" ]]
    then
        echo "### Prepreping Git for upload ###"
        git add *
        git commit -a -m "${timestamp}"
        git push
    else
        echo "### ERROR: Failed to upload to Git ###"
        exit 0
    fi    
}

function run_scripts {
    echo "### Running $1 scripts ###"
    for i in `ls scripts/$1/*.sh` ;
    do
        echo "### Running $i ###"
        sudo /bin/bash $i ;
    done
    echo "### DONE ###"
}

check_env
run_scripts repack
git_upload
