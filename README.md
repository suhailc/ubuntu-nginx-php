#c4-bootstrap

A quick and simple configuration tool to build servers (cloud or real) to a consitant install level, provided by channel4.com

##Concept

c4-bootstrap is designed to help you deploy repeatable physical or cloud servers. This is achieved by starting with a base config (c4-bootstrap) and building system configs and start up scripts which you then store in git ready to be used in the future. The files directory within this repo is used to store any file that you wish to be installed on another system. This maybe a custom _/etc/nginx/nginx.conf_ file for example. For ease of use you should consider _files/_ as a mirror image of your _/_ directory.
The scripts are split into three types, pre.d, post.d and repack. The later is used only by the repack.sh script to pull in file system changes into the files directory. *pre.d* is used by bootstrap.sh to configure and prep the system before files/ is expanded onto the root file system, an example of what you may do in pre.d scripts would be _apt-get install nginx_. *post.d* is used to configure any of the system after the the files have been expanded, an example of this may be _a2ensite mysite.conf_

##Requirements

git-core
bash
Ubuntu
tar
gzip

##HOWTO c4-bootstrap

Fire up your Ubuntu server or EC2 instance.

Now clone this git repo onto your new server:

    git clone https://github.com/channel4/c4-bootstrap.git

You now need to update you git remote server path so you can commit changes back to your private repo, thus creating a repeatable server settings repo:

    git .....

Create some custom scripts to install software and prep the system in scripts/pre.d (make sure they are bash scripts)

Now populate files/ with any files you wish to be included on the system.

Finally you should now create ony post file expansion tasks in scripts/post.d

If you now run ./bootstrap.sh you should see your actions being carried out on the server.

Don't forget to commit your changes back to git.

    git add *
    git commit -a
    git push

Now one a fresh server you can simply:

    git clone https://github.com/channel4/c4-bootstrap.git
    ./bootstrap.sh

This will replicate your system onto the new server.

##HOWTO c4-repack

repack.sh is designed to help you manage servers that are already bootstraped. Once you have a bootstrapped server edit scripts/repack/00-suckfiles.sh and add more directories to the _working dirs()_ array. This will then allow the repack.sh script to copy these folders/files into the bootstrap files/ directory. On running repack.sh this will automatically copy your configured files into the system and commit them back to git.

##The System

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


