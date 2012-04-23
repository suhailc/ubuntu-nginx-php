#c4-bootstrap

This project is a lightweight framework for configuring, administrating and building servers consistently at the install level. It is designed for both the cloud and 'real' hardware. It is currently actively developed and maintained by channel4.com.

##Concept

c4-bootstrap is designed to aid repeatable deployment of physical and cloud servers. It uses the concept of "infrastructure as code", allowing the use of git to version control entire deployment strategies. 

Building and deploying systems manually can be construed in three main stages. These are namely; a) installing the base packages, b) copying core files to the server and c) tweaking the relevenet configuration files. 

###Core components

To replicate this we've developed a lightweight configuration package which consists of several components.

i) _scripts/pre.d_ which installs your base packages.
ii) A _files/_ directory which mimics the server root. (For ease of use you should consider _files/_ as a mirror image of your _/_ directory). It is copied onto the system after _pre.d_.
iii) _scripts/post.d_ which is essentially the configuration stage; it is constituted of scripts which run after stages i. and ii, and configure the environment.

###Additional components

Additional to the above, we provide _repack.sh_. This script enables changes made on the system to be pulled back into the git repo to store for a later date. 

N.b. if extra packages are installed on the system via a package manager such as apt-get, the install scripts in _scripts/pre.d_ will need to be updated to reflect this so that all the requirements are present on system rebuild.

##Sub Projects

The main c4-bootstrap project is designed to be the core framework for other sub-projects to extend. The core scripts can be reused and tracked by forking this project and we do accept pull requests for new features and bug fixes! If you have an interesting system build using c4-bootstrap please let us know and we'll list them on the wiki.

##Requirements

These scripts have only been tested on an Ubuntu based distro but should be easily altered to run elsewhere.

    git-core
    
You can install git on a fresh system by issuing these commands:

    sudo apt-get update
    sudo apt-get install git-core

These toolkits are required, and should be standard on most linux distro's:

    bash
    tar
    gzip

##HOW TO c4-bootstrap

i.    Fire up a fresh Ubuntu server or EC2 instance. ( see www.ubuntu.com for install and operational instructions )


ii.   Fork this git repo and clone to the new server:

      First click the fork button on the c4-bootstrap github page
    
      Then using your details amend the following:
    
      git clone https://github.com/*<USERNAME>*/c4-bootstrap.git
      cd c4-bootstrap
    
    
iii.  Now keep track of upstream script changes:

      git remote add upstream git://github.com/channel4/c4-bootstrap.git
      git fetch upstream


iv.   Create custom bash scripts for software and system configuration, storing them in scripts/pre.d


v.    Populate files/ with any files to be included on the system.


vi.   Finally create any required post file expansion tasks in scripts/post.d


vii.  If you now run ./bootstrap.sh; you should see your actions being carried out on the server.


viii. Commit the above created changes back to the git repository.

      git add *
      git commit -a
      git push origin master


Now on a fresh server you can simply type:

    git clone https://github.com/<USERNAME>/c4-bootstrap.git
    ./bootstrap.sh

This will replicate steps ii. - vii. for your new system.



##HOW TO c4-repack

repack.sh is designed to help you manage servers that are already bootstraped. Prelimenary to running repack.sh, edit  scripts/repack/00-suckfiles.sh and add any additional directories to the _working dirs()_ array. This allows the repack.sh script to copy these specified folders/files into the bootstrap files/ directory. 

Now when you run repack.sh, these files will be automatically copied into the system and committed back to git.



####Environment checks
On running the bootstrap.sh script the system checks for the system distrobution name and the version. The version number can be tweaked at the top of the file by altering the following variable:

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

