#c4-bootstrap

A quick and lightweight configuration tool to build servers (cloud or real) to a consistent install level, provided by channel4.com.

##Concept

c4-bootstrap is designed to help you deploy repeatable physical or cloud servers using git as version control. When you build systems by hand there are normally three main stages. You start by installing the base packages, you then copy your files to the server and finally you tweak your config files. 

To replicate this we've developed the lightweight configuration package which consists of _scripts/pre.d_ which installs your base packages, the _files/_ directory which mimics the root of your server (For ease of use you should consider _files/_ as a mirror image of your _/_ directory) and is copied onto the system after _pre.d_ is run then the _scripts/post.d_ which you can use to configure your system.

We also provide a script called _repack.sh_, which enables you to pull changes you've made on your system back into the git repo to store for a later date. One thing you should note that if you install extra packages on your system via a package manager such as apt-get you need to update your install scripts in _scripts/pre.d_ so that when you rebuild a system all the requirements are there.

##Sub Projects

The main c4-bootstrap project is designed to be the basis for many sub projects that are far more complex. The core scripts can be reused and tracked by forking this project and we do accept pull requests for new features and bug fixes! If you have an interesting system build using c4-bootstrap please let us know and we'll list them on the wiki.

##Requirements

These scripts have only been tested on an Ubuntu based distro but should be easily altered to run elsewhere.

    git-core
    
You can install git on a fresh system by issuing these commands:

    sudo apt-get update
    sudo apt-get install git-core

These will be standard on most linux distro's:

    bash
    tar
    gzip

##HOWTO c4-bootstrap

Fire up your Ubuntu server or EC2 instance.

Now fork this git repo and clone onto your new server:

    First click the fork button on the c4-bootstrap github page
    
    Then using your details amend the following:
    
    git clone https://github.com/*<USERNAME>*/c4-bootstrap.git
    cd c4-bootstrap
    
Now keep track of upstream script changes:

    git remote add upstream git://github.com/channel4/c4-bootstrap.git
    git fetch upstream

Create some custom scripts to install software and prep the system in scripts/pre.d (make sure they are bash scripts)

Now populate files/ with any files you wish to be included on the system.

Finally you should now create your post file expansion tasks in scripts/post.d

If you now run ./bootstrap.sh you should see your actions being carried out on the server.

Don't forget to commit your changes back to git.

    git add *
    git commit -a
    git push origin master

Now one a fresh server you can simply:

    git clone https://github.com/<USERNAME>/c4-bootstrap.git
    ./bootstrap.sh

This will replicate your system onto the new server.

##HOWTO c4-repack

repack.sh is designed to help you manage servers that are already bootstraped. Once you have a bootstrapped server edit scripts/repack/00-suckfiles.sh and add more directories to the _working dirs()_ array. This will then allow the repack.sh script to copy these folders/files into the bootstrap files/ directory. On running repack.sh this will automatically copy your configured files into the system and commit them back to git.

##The System

###bootstrap.sh
bootstrap.sh allows you to quickly setup your system to specified environment, it will run pre.d and post.d scripts and also copy your directory structure from files to the root of the system. The following explains how the script works. The order of the system bootstrap is:

1. pre.d scripts are executed setting up your core components
2. files are then copied tot he root of your system
3. post.d scripts are then used to change configuration settings

####Environment checks
On running the bootstrap.sh scrip the system checks for the system distro name and the version. The version number can be tweaked at the top of the file by altering the following variable:

    supported_dist="Ubuntu"
    supported_vers="10.04"

To set the script to not copy files to the root directory change the following value to 0.

    prod=1

We currently track the LTS version of Ubuntu so the core scripts will soon change to 12.04 but they should work on any version.

####pre.d scripts
The script will then iterate through scripts/pre.d/XXXX and run each script in order. These are simply bash scripts to perform initial tasks such as install dependencies. An example script is provided. Scripts are run in order so 00-.... will be run before 01-....

####exploding files
This part of the script takes the contents of files/.... and copies them to / This allows you to include files such as a custom motd or something more useful like a sites-enabled config for nginx or apache. To set the script to not copy files to the root directory change the following value to 0 in this case the files will be copied to /tmp/c4-bootstrap.

    prod=0

####post.d
The final part of the script is post.d. This is called in the same way as pre.d and iterates through scripts/post.d/XXXX. In post.d you should run things that can only be done once the software is installed and the files are in place. An example of this would be _*a2ensite mysite.conf*_. Yet again these are bash scripts and will be run in numerical order.

###repack.sh
repack.sh allows you to commit local system changes back to a git repo in order repeat these changes on other servers.

####Environment checks
On running the repack.sh scrip the system checks for the system distro name and the version. The version number can be tweaked at the top of the file by altering the following variable:

    supported_dist="Ubuntu"
    supported_vers="10.04"

This ensures that you are packaging for the same version as the bootstrap.sh


####repack scripts
The repack scripts live in the scripts/repack directory. Care should be taken when editing current scripts or adding to this directory.
#####00-suckfiles.sh
By default __00-suckfiles.sh__ doesn't back anything up. In order to make it back up simply create a file called __scripts/repack/working_dirs__ and list on separate lines which directories you wish to be backed up:

    /var/www/
    /etc/apache2/
    .....

All these files will then be pulled into your github __files__, the only folder we treat differently is __/var/www/__ because generally this has a large number of files we create a tar.gz of this to be expanded at boot strap time.

###Files

The file structure of the system is kept within files, this should be treated as a mirror of your root / for example files/etc/nginx/nginx.conf after bootstrap.sh is run will map to /etc/nginx/nginx.conf

