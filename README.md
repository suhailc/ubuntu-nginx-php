#c4-bootstrap

A quick and simple configuration tool to build servers (cloud or real) to a consitant install level, provided by channel4.com

##Concept

c4-bootstrap is split into to major scripts and two directory structures. 

##Requirements

git-core
bash
Ubuntu

##HOWTO c4-bootstrap

##Commands in Detail

###bootstrap.sh
bootstrap.sh allows you to quickly setup your system to specified environment, it will run pre.d and post.d scripts and also copy your directory structure from files to the root of the system. The follow explains how the script works.

####Environment checks
On running the bootstrap.sh scrip the system checks for the system distro name and the version. The version number can be tweaked at the top of the file by altering the followinf variable:

    supported_dist="Ubuntu"
    supported_vers="10.04"

To set the script to not copy files to the root directory change the following value to 0.

    prod=1

####pre.d scripts
The script will then itterate through scripts/pre.d/XXXX and run each script in order. These are simply bash scripts to perform initial tasks such as install dependancies. An example script is provided. Scripts are run in order so 00-.... will be run before 01-....

####exploding files
This part of the script takes the contents of files/.... and copies them to / This allows you to include files such as a custom motd or something more useful like a sites-enabled config for nginx or apache. To set the script to not copy files to the root directory change the following value to 0 in this case the files will be copied to /tmp/c4-bootstrap.

    prod=0

####post.d
The final part of the script is post.d. This is called in the same way as pre.d and itterates through scripts/post.d/XXXX. In post.d you should run things that can only be done once the software is installed and the files are in place. An example of this would be _*a2ensite mysite.conf*_. Yet again these are bash scripts and will be run in numerical order.

###repack.sh
repack.sh allows you to commit local system changes back to a git repo in order repeat these changes on other servers.

####Environment checks
On running the repack.sh scrip the system checks for the system distro name and the version. The version number can be tweaked at the top of the file by altering the followinf variable:

    supported_dist="Ubuntu"
    supported_vers="10.04"

This ensures that you are packaging for the same version as the bootstrap.sh

####repack scripts
The repack scripts live in the scripts/repack directory. Care should be taken when editing current scripts or adding to this directory.
#####00-suckfiles.sh
suck files enables repack.sh to pull back into the local directory all the changes you've made on the system in specified directories. in the example script it purely backs up /var/www. It handles /var/www in a special way to compensate for the fact you may have a lot of files in that location by tar.gz the directory and storing it in files/var/tmp/SiteContent.tgz this is also referenced by bootstrap.sh and is exploded in post.d/00-explode-files.sh

Other directories specified are simply copied to files/....... verbatum.

You can add extra locations to be backed up by modifying the array below in scripts/repack/00-suckfiles.sh:

    working_dirs=( /var/www/ )

the folowing would also copy the contents of /etc/apache2/

    working_dirs=( /var/www/ /etc/apache2/ )

##Files

The file structure of the system is kept within files, this should be treated as a mirror of your root / for example files/etc/nginx/nginx.conf after bootstrap.sh is run will map to /etc/nginx/nginx.conf


