# c4-bootstrap

This project is a lightweight framework for configuring, administrating and building servers consistently at the install level. It is designed for both the cloud and 'real' hardware. It is currently actively developed and maintained by channel4.com.

## Concept

c4-bootstrap is designed to aid repeatable deployment of physical and cloud servers. It uses the concept of "infrastructure as code", allowing the use of github to version control entire deployment strategies. 

Building and deploying systems manually can be described abstracted to three main stages. These are namely; 
i)   installing the base packages, 
ii)  copying core files to the server, and 
iii) tweaking the relevant configuration files. 

### Core Components

To replicate this we've developed a lightweight configuration package which consists of several components.

i)   _scripts/pre.d_ which installs your base packages.

ii)  A _files/_ directory which mimics the server root. (For ease of use you should consider _files/_ as a mirror image of your _/_ directory). It is copied onto the system after _pre.d_.

iii) _scripts/post.d_ which is essentially the configuration stage; it is constituted of scripts which run after stages i. and ii, and configure the environment.

### Additional Components

Additional to the above, we provide _repack.sh_. This script enables changes made on the system to be pulled back into the git repo to store for a later date. 

N.b. if extra packages are installed on the system via a package manager such as apt-get, the install scripts in _scripts/pre.d_ will need to be updated to reflect this so that all the requirements are present on system rebuild.

### Sub Projects

The main c4-bootstrap project is designed to be the core framework for other sub-projects to extend. The core scripts can be reused and tracked by forking this project. Additionally, we do accept pull requests for new features and bug fixes! If you have an interesting system build using c4-bootstrap please let us know and we'll list them on the Wiki.

## System Requirements

These scripts have only been tested on an Ubuntu based distro but should be easily altered to run elsewhere.

    git-core
    
You can install git on a fresh system by issuing these commands:

    sudo apt-get update
    sudo apt-get install git-core

The following toolkits are required, and should be standard on most Linux distro's:

    bash
    tar
    gzip

## How To: c4-bootstrap

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



## How To: c4-repack

repack.sh is designed to help you manage servers that are already bootstrapped. Preliminary to running repack.sh, edit  scripts/repack/00-suckfiles.sh and add any additional directories to the _working dirs()_ array. This allows the repack.sh script to copy these specified folders/files into the bootstrap files/ directory. 

Now when you run repack.sh, these files will be automatically copied into the system and committed back to git.

#### Environment checks

On running the bootstrap.sh script, the system checks for current distro name and version. To change the version number, alter the following variable found at the top of the script:

    supported_dist="Ubuntu"
    supported_vers="10.04"

To prevent the script from copying files to the root directory, change the following variable to 0:

    prod=1 //change to 0;

We currently track the LTS version of Ubuntu so the framework scripts will soon change to 12.04 but should continue to work on any version.


## Stages in more detail.

#### pre.d scripts (stage i)

The pre.d scripts are the initial component. The framework will iterate through scripts/pre.d/XXXX and run each script in order. These scripts should be simple bash scripts performing initial tasks such as installing dependencies. An example script is provided. Script order processing is deduced from a prefix number, e.g. script 00-example will be run before 01-example.

#### exploding files (stage ii)

This part of the framework takes the contents of files/.... and copies them to /. This allows you to include files such as a custom motd or elements such as a sites-enabled config for nginx or apache. 

To re-route copying of files to /tmp/c4-bootstrap instead of the / directory, change variable prod in bootstrap.sh to 0.

    prod=0

#### post.d (stage iii)

The final part of the framework is post.d. This is approached in the same manner as pre.d, iterating through scripts/post.d/XXXX, using number pre-fixes to determine order. Scripts located in post.d should run commands that can only be done once the software is installed and files are shifted to the correct location. 

An example of this would be _*a2ensite mysite.conf*_.

### repack.sh

repack.sh allows you to commit local system changes back to a git repo in order to repeat/capture changes for future deployments.

#### Environment checks

When running the repack.sh script the system checks for the distro name and version. As mentioned above, the version number can be tweaked at the top of the file by altering the following variable:

    supported_dist="Ubuntu"
    supported_vers="10.04"

This ensures that you are packaging for the same version as bootstrap.sh


#### Repack scripts

The repack scripts reside in:

    scripts/repack. 

Care should be taken when editing existing scripts or adding files to this directory.

##### 00-suckfiles.sh

By default __00-suckfiles.sh__ does not back anything up. 

To back up specified folders; create a file called __scripts/repack/working_dirs__ and list on separate lines which directories you wish to back up; e.g.

    /var/www/
    /etc/apache2/
    .....

All these files will then be pulled into your github __files__.

The only folder treated differently is __/var/www/__. Because this generally has a large number of files, we create a tar.gz of this, which is expanded at boot strap time.

### Files

The file structure of the system is kept within files, this should be a mirror of your root / directory.
For example, after bootstrap.sh is run, files/etc/nginx/nginx.conf will map to /etc/nginx/nginx.conf.

