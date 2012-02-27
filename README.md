#c4-bootstrap

A quick and simple configuration tool to build servers (cloud or real) to a consitant install level, provided by channel4.com

##Concept

c4-bootstrap is split into to major scripts and two directory structures. 

##Requirements

##Commands

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
whilst repack.sh allows you to commit local system changes back to a git repo in order repeat these changes on other servers.

###Files

The file structure of the system is kept within files, this should be treated as a mirror of your root / for example files/etc/nginx/nginx.conf after bootstrap.sh is run will map to /etc/nginx/nginx.conf

