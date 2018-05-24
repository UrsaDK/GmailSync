GmailSync
=========

**Version:** 1.2.0  
**Status:** Fully functional, but missing tests.

A script to facilitate migration of mail from one Gmail account to another. During the migration all To, From, Cc and Bcc headers matching the old account are rewritten to match the new account.

Requirements
------------

- imapsync -- IMAP transfers tool, see http://imapsync.lamiral.info

- mail -- a command line mail utility used to send and receive mail

Synopsis
--------

    gmailsync [options] [argument]

    A wrapper around imapsync to help with migration of gmail accounts.

        Options                 All options are optional and
        -------                 can be supplied in any order.

        Server connection details:

        -i --imapsync=path      Location of the imapsync script
        -t --timeout=seconds    Timeout between server operations

        Source properties (from):

        --user1=username        Account username (gmail address)
        --pass1=password        Account password
        --host1=hostname        Hostname or IP address
        --port1=number          Port on which IMAP is listening

        Target properties (to):

        --user2=username        Account username (gmail address)
        --pass2=password        Account password
        --host2=hostname        Hostname or IP address
        --port2=number          Port on which IMAP is listening

        Generic output options:

        -r --report=email       Email activity log to this address
        -l --log=path           Log output to a file
        -q --quiet              Suppress output of the script
        -? --help               Display this help message
        --version               Script and BASH version info

        Arguments               All agruments are optional and
        ---------               can be supplied in any order.

        A list of folders (space separated) which are to be
        synchronise between the accounts.

    <> - required parameters    [] - optional parameters
    Use 'less ${0}' to view further documentation.

Changelog
---------

* 1.2.0

  - The script no longer deletes it's log file
  - Default values for all options can now be set by defining a GMAILSYNC_LONG_OPTION_NAME variables (all caps). For example, defining `export GMAILSYNC_IMAPSYNC=/bin/true` will use `/bin/true` as the default value for `--imapsync` option.

* 1.1.0

  - Added a user friendly help message and support for command line parameters. Improved error handling: the script now exit with error code as per shell standard, all error messages are logged via STDERR.

* 1.0.0

  - Initial release of the code.

Donations
---------

This script is 100% free and is distributed under the terms of the MIT license. You're welcome to use it for private or commercial projects and to generally do whatever you want with it.

If you found this script useful, would like to support its further development, or you are just feeling generous, then your contribution will be greatly appreciated!

<p align="center">
  <a href="https://paypal.me/UmkaDK"><img src="https://img.shields.io/badge/paypal-me-blue.svg?colorB=0070ba&logo=paypal" alt="PayPal.Me"></a>
  &nbsp;
  <a href="https://commerce.coinbase.com/checkout/252e79ee-242f-40bc-9351-1538145061fa"><img src="https://img.shields.io/badge/coinbase-donate-gold.svg?colorB=ff8e00&logo=bitcoin" alt="Donate via Coinbase"></a>
</p>
