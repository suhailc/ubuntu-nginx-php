#!/bin/sh

dpkg --set-selections < /var/tmp/files/additional-software
apt-get update && apt-get -u dselect-upgrade

