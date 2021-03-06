A git merge driver for MediaWiki-style release notes.

Requires Ruby and a Bourne-compatible shell.

Usage / Installation
--------------------

    cd mediawiki/core
    sh mediawikireleasenotes-driver-installer.sh

You can also use the following command to get and install the latest version
directly from the GitHub repository:

    curl -L https://raw.github.com/MatmaRex/mediawikireleasenotes-driver/master/mediawikireleasenotes-driver-installer.sh | sh

From this point on, all merges of RELEASE-NOTES files will use the new algorithm.

How it works
------------

The installer drops the driver itself into the .git directory of the repo you're in,
configures the repo to know about it, and uses [gitdir]/info/attributes file to
define it as the default driver for release notes file.

The driver is a simple script that analyzes the contents of files to be merged,
determines release notes that have been added to each section[1] of one of the
files and transplants them to the other one.

This allows for a conflictless merge in most simple cases, and doesn't break in
complicated situations.

[1] Sections are assumed to start with a MediaWiki-style ==Header==.

Showcase
--------

To quickly test how this works, you can use a little test repo generated using
the following commands:

    git init testrepo
    cd testrepo
    echo "Our release notes." > RELEASE-NOTES.txt
    git add RELEASE-NOTES.txt
    git commit -am "initial commit"
    git checkout -b firstbranch
    echo "* First addition to release notes." >> RELEASE-NOTES.txt
    git commit -am "commit on firstbranch"
    git checkout master
    git checkout -b secondbranch
    echo "* Another release note. Let's hope it doesn't conflict!" >> RELEASE-NOTES.txt
    git commit -am "commit on secondbranch"
    git checkout master

Then try the following in any order, with this driver installed or missing:

    git merge firstbranch
    git merge secondbranch

With the driver, both branches should merge seamlessly; without it, the second
merge will cause a merge conflict.

License
-------

Version 2.

Any of:
* GNU GPL 2 or newer
* CC BY 3 or newer
