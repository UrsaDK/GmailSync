#!/usr/bin/env bash

VERSION='1.2.0'

# CONFIGURATION
# =============

# Configure default imapsync location
: ${GMAILSYNC_IMAPSYNC:="$(`which imapsync`)"}

# List default folders that we would like to transfer
: ${GMAILSYNC_FOLDERS:=( 'INBOX' 'All Mail' 'Bin' 'Drafts' 'Starred' 'Sent Mail' )}

# Define location of the log file where to store imapsync messages
: ${GMAILSYNC_LOG:='/dev/null'}

# An email address to which to sent current activity log
: ${GMAILSYNC_REPORT:=''}

# Configure system timeout (in seconds)
: ${GMAILSYNC_TIMEOUT:=10}

# Define parameters for the origin (from) account
: ${GMAILSYNC_USER1:=''}
: ${GMAILSYNC_PASS1:=''}
: ${GMAILSYNC_HOST1:='imap.gmail.com'}
: ${GMAILSYNC_PORT1:='993'}

# Define parameters for the destination (to) account
: ${GMAILSYNC_USER2:=''}
: ${GMAILSYNC_PASS2:=''}
: ${GMAILSYNC_HOST2:='imap.gmail.com'}
: ${GMAILSYNC_PORT2:='993'}

# Do not modify anything below this point
# ---------------------------------------

# Configure default imapsync parameters
ARG_IMAPSYNC='--dry --syncinternaldates --skipsize --useheader "Date" --useheader "Message-ID"'

# Configure imapsync parameters for the origin and destination server
ARG_IMAPSERV1='--ssl1 --authmech1 LOGIN --split1 100'
ARG_IMAPSERV2='--ssl2 --authmech2 LOGIN --split2 100'

# Configure imapsync parameters for staggered mail transfer by message age
ARGS_STAGGER=(
    '--minage 1090'
    '--maxage 1091 --minage 999'
    '--maxage 1000 --minage 908'
    '--maxage 909 --minage 817'
    '--maxage 818 --minage 726'
    '--maxage 727 --minage 635'
    '--maxage 636 --minage 544'
    '--maxage 545 --minage 453'
    '--maxage 454 --minage 362'
    '--maxage 363 --minage 271'
    '--maxage 272 --minage 180'
    '--maxage 181 --minage 89'
    '--maxage 90'
)

# SYNOPSIS
# ========

# Document available command line options. This function
# simply outputs script's SYNOPSIS to the user terminal.
__help() {
cat << EOF
Usage:
    ${0} [options] [arguments]

    A wrapper around imapsync to help with migration of gmail accounts.

        Options                 All options are optional and
        -------                 can be supplied in any order.

        Server connection details:

        -i --imapsync=<path>    Location of the imapsync script
                                Default: $(default_val GMAILSYNC_IMAPSYNC)
        -t --timeout=<seconds>  Timeout between server operations
                                Default: $(default_val GMAILSYNC_TIMEOUT)

        Source properties (from):

        --user1=<username>      Account username (gmail address)
                                Default: $(default_val GMAILSYNC_USER1)
        --pass1=<password>      Account password
                                Default: $(default_val GMAILSYNC_PASS1)
        --host1=<hostname>      Hostname or IP address
                                Default: $(default_val GMAILSYNC_HOST1)
        --port1=<number>        Port on which IMAP is listening
                                Default: $(default_val GMAILSYNC_PORT1)

        Target properties (to):

        --user2=<username>      Account username (gmail address)
                                Default: $(default_val GMAILSYNC_USER2)
        --pass2=<password>      Account password
                                Default: $(default_val GMAILSYNC_PASS2)
        --host2=<hostname>      Hostname or IP address
                                Default: $(default_val GMAILSYNC_HOST2)
        --port2=<number>        Port on which IMAP is listening
                                Default: $(default_val GMAILSYNC_PORT2)

        Generic output options:

        -r --report=<email>     Email activity log to this address
                                Default: $(default_val GMAILSYNC_REPORT)
        -l --log=<path>         Log output to a specified file
                                Default: $(default_val GMAILSYNC_LOG)
        -q --quiet              Suppress output of the script
        -? --help               Display this help message
        --version               Script and BASH version info

        Arguments               All agruments are optional and
        ---------               can be supplied in any order.

        A list of folders (space separated) which are to be
        synchronise between the accounts.

        Default: ${GMAILSYNC_FOLDERS}

    <> - required parameters    [] - optional parameters
    Use 'less ${0}' to view further documentation.
EOF
}

# FUNCTIONS
# =========

# This function is executed after processing all supplied
# options but before looking at the script's arguments.
__init() {
    INIT_DIR="$pwd"
    cd $(dirname ${0})
}

# This function is called when the script receives an EXIT pseudo-signal. It
# simulates a common destructor behaviour inside BASH scripts. It allows this
# script to release and clean up resources upon termination.
__exit() {
    if [[ -n "${GMAILSYNC_REPORT}" ]]; then
        echo "Emailing result to ${GMAILSYNC_REPORT}" >&5
        local msg="[GmailSync] Finished migrating ${GMAILSYNC_USER1} to ${GMAILSYNC_USER2}"
        cat ${GMAILSYNC_LOG} | mail -s "${msg}" -c "${GMAILSYNC_REPORT}"
    fi
    cd ${INIT_DIR}
}

# Insure the presence of OPTARG in the current scope. If OPTARG is missing then
# display help message via __help and exit with an error code.
require_OPTARG() {
    if [[ -z ${OPTARG} ]]; then
        echo "${0}: option requires an argument -- ${OPTKEY}" >&2
        __help
        exit 1
    fi
}

# Show defalt value of a variable name by the first argument
default_val() {
    if [[ -z ${!1} ]]; then
        echo '[none]'
    else
        echo "${!1}"
    fi
}

# Show message on the screen but do not appended it to the log
say() {
    if [[ -z ${CFG_REPORT} ]]; then
        echo ${@} >&5
    fi
}

# Append message to the log but do not show it on the screen
log() {
    if [[ -n ${GMAILSYNC_LOG} ]]; then
        echo ${@}
    fi
}

# COMMAND LINE OPTIONS
# =====================
#
# By default BASH does not provide support for long options. However, we can
# trick it into doing so by defining '-:' as part of the optspec. This
# exploits a non-standard behaviour of the shell which permits the
# option-argument to be concatenated to the option, eg: -f arg == -farg
while getopts "i:r:t:l:q?-:" OPTKEY; do

    if [[ "${OPTKEY}" = '-' ]]; then
        OPTKEY=`echo ${OPTARG} | sed -e 's/=.*//'`
        OPTARG=`echo ${OPTARG} | sed -e "s/^${OPTKEY}=\{0,1\}//"`
    fi

    case ${OPTKEY} in
        'i'|'imapsync')
            require_OPTARG
            GMAILSYNC_IMAPSYNC=${OPTARG}
            ;;
        't'|'timeout')
            require_OPTARG
            GMAILSYNC_TIMEOUT=${OPTARG}
            ;;

        'user1')
            require_OPTARG
            GMAILSYNC_USER1=${OPTARG}
            ;;
        'pass1')
            require_OPTARG
            GMAILSYNC_PASS1=${OPTARG}
            ;;
        'host1')
            require_OPTARG
            GMAILSYNC_HOST1=${OPTARG}
            ;;
        'port1')
            require_OPTARG
            GMAILSYNC_PORT1=${OPTARG}
            ;;

        'user2')
            require_OPTARG
            GMAILSYNC_USER2=${OPTARG}
            ;;
        'pass2')
            require_OPTARG
            GMAILSYNC_PASS2=${OPTARG}
            ;;
        'host2')
            require_OPTARG
            GMAILSYNC_HOST2=${OPTARG}
            ;;
        'port2')
            require_OPTARG
            GMAILSYNC_PORT2=${OPTARG}
            ;;

        'r'|'report')
            require_OPTARG
            GMAILSYNC_REPORT=${OPTARG}
            ;;
        'l'|'log')
            require_OPTARG
            GMAILSYNC_LOG=${OPTARG}
            mkdir -p $(dirname ${GMAILSYNC_LOG})
            exec 5>&1 6>&2
            exec > ${GMAILSYNC_LOG} 2>&1
            ;;
        'q'|'quiet')
            exec 5>&1 6>&2
            exec 1>&-
            ;;
        'version')
            echo "Shell script $0 version ${VERSION}"
            echo `bash --version | head -n 1`
            exit
            ;;
        '?'|'help')
            __help
            exit
            ;;
        *)
            if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                echo "${0}: illegal option -- ${OPTKEY}" >&2
                __help
                exit 1
            fi
            ;;
    esac
done

# Clear all options and reset the command line argument count
shift $(( OPTIND -1 ))

# Check for an option-terminator string
if [[ "${1}" == "--" ]]; then
    shift
fi

# Verify that imapsync command exists
if [[ ! -x ${GMAILSYNC_IMAPSYNC} ]]; then
    echo "${0}: illegal configuration -- imapsync command is missing" >&2
    __help
    exit 1
fi

# Verify that the username and password are supplied for both IMAP servers
for i in 1 2; do
    user="GMAILSYNC_USER${i}"
    pass="GMAILSYNC_PASS${i}"
    host="GMAILSYNC_HOST${i}"
    port="GMAILSYNC_PORT${i}"

    # Terminate execution if user, host or port are missing
    if [[ -z ${!user} ]] || [[ -z ${!host} ]] || [[ -z ${!port} ]]; then
        echo "${0}: illegal configuration -- define all of the following:" >&2
        echo "   Server 1: username, password, hostname and port" >&2
        echo "   Server 2: username, password, hostname and port" >&2
        exit 1
    fi

    # Request the user to enter a password if it is missing
    if [[ ! ${!pass} ]] || [[ -z ${!pass} ]]; then
        read -rsp "Please enter the password for ${!user}:" ${!pass}
        echo
    fi
done

# Initialise script destructor
trap __exit EXIT
__init

# SCRIPT ACTUAL
# =============

# Convert command line arguments into a list of folders
if [[ ${!#} != ${0} ]]; then
    GMAILSYNC_FOLDERS=( "${@}" )
fi

# Configure imapsync to rewrite old account mail address to the new one
ESC_USER1=`echo ${GMAILSYNC_USER1} | sed 's/@/\\\\@/'`
ESC_USER2=`echo ${GMAILSYNC_USER2} | sed 's/@/\\\\@/'`
ARGS_REWRITE=(
    "s/Delivered-To: ${ESC_USER1}/Delivered-To: ${ESC_USER2}/gi"
    "s/<${ESC_USER1}>/<${ESC_USER2}>/gi"
    "s/^((To|From|Cc|Bcc):.*)${ESC_USER1}(.*)$/\$1${ESC_USER2}\$3/gim"
    's/Subject:(\s*)\n/Subject: (no--subject)$1\n/ig'
    's/Subject: ([Rr][Ee]):(\s*)\n/Subject: $1: (no--subject)$2\n/gi'
)

# Consolidate rewrite rules into a single argument
ARG_REWRITE=''
for regex in "${ARGS_REWRITE[@]}"; do
    ARG_REWRITE="${ARG_REWRITE} --regexmess '${regex}'"
done

# Consolidate all parameters into a single variable
ARG_IMAPSERV1="${ARG_IMAPSERV1} --host1 '${GMAILSYNC_HOST1}' --port1 ${GMAILSYNC_PORT1} --user1 '${GMAILSYNC_USER1}' --password1 '${GMAILSYNC_PASS1}"
ARG_IMAPSERV2="${ARG_IMAPSERV2} --host2 '${GMAILSYNC_HOST2}' --port2 ${GMAILSYNC_PORT2} --user2 '${GMAILSYNC_USER2}' --password2 '${GMAILSYNC_PASS2}"
ARG_IMAPSYNC="${ARG_IMAPSYNC} ${ARG_IMAPSERV1} ${ARG_IMAPSERV2} ${ARG_REWRITE}"

# Process all folders one by one
for folder in "${GMAILSYNC_FOLDERS[@]}"; do
    # Tell user what we are doing
    say "Processing folder: ${folder}"

    # Process message chunks in folders
    for arg_stagger in "${ARGS_STAGGER[@]}"; do
        # Tell user & log what we are about to do
        say "  Retrieving time period : ${arg_stagger}"
        log ""
        log "*** ${folder} ${arg_stagger} ***"
        log ""

        # Run command until it succeeds
        echo "${GMAILSYNC_IMAPSYNC} ${ARG_IMAPSYNC} ${arg_stagger}"
        until `${GMAILSYNC_IMAPSYNC} ${ARG_IMAPSYNC} ${arg_stagger}`; do
            # Tell logfile what we are doing
            log ""
            log "***** NOT COMPLETE - ${folder} ${arg_stagger} *****"
            log ""

            # Initialise requested timeout
            if [ ${GMAILSYNC_TIMEOUT} ]; then
                message="Sleeping for ${GMAILSYNC_TIMEOUT}..."
                say "  ${message}"
                log -n "${message}"
                sleep ${GMAILSYNC_TIMEOUT}
            fi

            log "Done."
        done

        # Tell logfile what we are doing
        log ""
        log "***** COMPLETE - ${folder} ${arg_stagger}*****"
        log ""
    done
done

# Terminate the script
log "**** DONE ****"
