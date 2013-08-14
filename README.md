GmailSync
=========

A script that facilitates transfer of mail from one Gmail account to another. 
During the transfer all To, From, Cc and Bcc headers matching the old account 
are rewritten to match the new account.

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

Description
-----------

**Requires:** [imapsync][]

GmailSync is a specialised script designed to facilitate transfer of mail from 
one gmail account to another. This need frequently arises when a user opens up 
either a new gmail or moves from their existing account to a new google apps 
account and wishes to transfer all their existing mail from the old account to 
the new one.

This script is a wrapper around [imapsync][] script, thus [imapsync][] is 
required in order to use this script.



[imapsync]: http://imapsync.lamiral.info/ "Official imapsync migration tool"
