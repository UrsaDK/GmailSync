GmailSync
=========

**Version:** 1.1.0  
**Status:** Fully functional, but missing tests.

A script that facilitates that facilitates transfer of mail from one Gmail account to another. During the transfer all To, From, Cc and Bcc headers matching the old account are rewritten to match the new account.

Requirements
------------

- imapsync  
  See: http://imapsync.lamiral.info

Synopsis
--------

    gmailsync [options] [argument]

        Where [arguments] is an optional, space separated list of folders
        which the user would like to synchronise between two accounts. While
        [options] could be any of the following:

        Server connection details:

        -i --imapsync=path      Location of the imapsync script
        -l --log=path           Log output to a file
        -r --report=email       Email activity log to this address
        -t --timeout=seconds    Timeout between server operations

        Properties of the origin (from) IMAP account:

        --user1=username        Account username (gmail address)
        --pass1=password        Account password
        --host1=hostname        Hostname or IP address
        --port1=number          Port on which IMAP is listening

        Properties of the destination (to) IMAP account:

        --user2=username        Account username (gmail address)
        --pass2=password        Account password
        --host2=hostname        Hostname or IP address
        --port2=number          Port on which IMAP is listening

        Generic output options:

        -q --quiet              Suppress output of the script
        -? --help               Display this help message
        --version               Script and BASH version info

    NOTE: If password to either account is not supplied then it will be
    requested from the user during normal script execution.

Changelog
---------

* 1.1

  - Added a user friendly help message and support for command line parameters. Improved error handling: the script now exit with error code as per shell standard, all error messages are logged via STDERR.

* 1.0  

  - Initial release of the code.
