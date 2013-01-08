A git merge driver for MediaWiki-style release notes.

Requires Ruby and a Bourne-compatible shell.

Usage / Installation
--------------------

    cd mediawiki/core
    sh mediawikireleasenotes-driver-installer.sh

From this point on, all merges of RELEASE-NOTES files will use the new algorithm.

How it works
------------

The installer drops the driver itself into the .git directory of the repo you're in,
configures the repo to know about it, and uses .gitattributes file to define it as
the default driver for release notes file.

The driver is a simple script that analyzes the contents of files to be merged, and
uses the union merge algorithm if there are only consecutive additions in both files
(no deletions, changes, or non-consecutive added lines). Otherwise it falls back to
the regular recursive merge algorithm.

This allows for a conflictless merge in most simple cases, and doesn't break in
complicated situations.

License
-------

Any of:
* GNU GPL 2 or newer
* CC BY 3 or newer
