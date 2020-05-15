<div align="center">

  [![GmailSync logo](https://avatars.githubusercontent.com/u/2833247?s=160)](#)<br>

  [![stable branch](https://img.shields.io/badge/dynamic/json.svg?logo=github&color=lightgrey&label=stable&query=%24.default_branch&url=https%3A%2F%2Fapi.github.com%2Frepos%2FUrsaDK%2FGmailSync)](https://github.com/UrsaDK/GmailSync)
  [![latest release](https://img.shields.io/badge/dynamic/json.svg?logo=github&color=blue&label=release&query=%24.name&url=https%3A%2F%2Fapi.github.com%2Frepos%2FUrsaDK%2FGmailSync%2Freleases%2Flatest)](https://github.com/UrsaDK/GmailSync/releases/latest)
  [![test coverage](https://codecov.io/gh/UrsaDK/GmailSync/graph/badge.svg)](https://codecov.io/gh/UrsaDK/GmailSync)
  [![donate link](https://img.shields.io/badge/donate-coinbase-gold.svg?colorB=ff8e00&logo=bitcoin)](https://commerce.coinbase.com/checkout/c97803c0-459a-4994-b940-9ae197d176b8)

</div>

# GmailSync

A script to facilitate migration of mail from one Gmail account to another. During the migration all To, From, Cc and Bcc headers matching the old account are rewritten to match the new account.

## Requirements

  - `imapsync` - IMAP transfers tool, see http://imapsync.lamiral.info
  - `mail` - a command line mail utility used to send and receive mail

## Synopsis

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
