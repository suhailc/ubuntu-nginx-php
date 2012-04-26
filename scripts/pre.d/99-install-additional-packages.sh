#!/bin/sh

dpkg --set-selections < files/var/tmp/additional-software
apt-get update && apt-get -uy dselect-upgrade

