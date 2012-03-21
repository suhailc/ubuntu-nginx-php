#!/bin/bash
# This script will unpack any old /var/www/ content if you have a SiteContent.tgz in your repo

for i in SiteContent.tgz ; do
    if [ -f /var/tmp/c4-bootstrap/${i} ]
    then
    echo "### Unpacking previous content ###"
        if [[ ${i} == "SiteContent.tgz" ]]; then STATIC_DIR=/var/www/public/ ; fi
        mkdir ${STATIC_DIR}
        tar xvfz /var/tmp/c4-bootstrap/${i} -C ${STATIC_DIR} --strip-components 3
    fi ;
done

