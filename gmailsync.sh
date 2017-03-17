#!/usr/bin/env bash

VERSION='1.1.0'

# List default folders that we would like to transfer
CFG_FOLDERS=( 'INBOX' 'All Mail' 'Bin' 'Drafts' 'Starred' 'Sent Mail' )

# Define location of the log file where to store imapsync messages
CFG_LOGFILE='/dev/null'

# An email address to which to sent current activity log
CFG_REPORT=''

# Configure system timeout (in seconds)
CFG_TIMEOUT=10

# Define parameters for the origin (from) account
CFG_USER1=''
CFG_PASS1=''
CFG_HOST1='imap.gmail.com'
CFG_PORT1='993'

# Define parameters for the destination (to) account
CFG_USER2=''
CFG_PASS2=''
CFG_HOST2='imap.gmail.com'
CFG_PORT2='993'

#################################################
##   Do not modify anything below this point   ##
##  If you do so, then do it at your own risk  ##
#################################################

# Configure default imapsync parameters
BIN_IMAPSYNC=`which imapsync`
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

# Document available command line options. This is a simple function that
# simply outputs script's SYNOPSIS to the user terminal.
__help() {
cat << EOF
Usage:
    ${0} [options] [arguments]

        Where [arguments] is an optional, space separated list of folders
        which the user would like to synchronise between two accounts. While
        [options] could be any of the following:

        Server connection details:

        -i --imapsync=path      Location of the imapsync script
        -l --log=path           Log output to a specified file
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

EOF
}

# This function is called when the script receives an EXIT signal. It
# simulates a common destructor behaviour inside BASH scripts. It allows this
# script to free and clean up resources upon termination.
__exit() {
    # Send report to an email address
    if [ ${CFG_REPORT} ]; then
        say "Emailing result to ${CFG_REPORT}"
        cat ${CFG_LOGFILE} | mail -s "[GmailSync] Finished importing mail for ${CFG_USER2}" -c "${CFG_REPORT}"
        rm -f ${CFG_LOGFILE}
    fi
}

say() {
    if [[ -z ${CFG_REPORT} ]]; then
        echo ${2} "${1}"
    fi
}

log() {
    echo ${2} "${1}" >> $CFG_LOGFILE
}

# Provide support for command line options.
#
# By default BASH does not provide support for long options. However, we can
# trick it into doing so by defining '-:' as part of the optspec. This
# exploits a non-standard behaviour of the shell which permits the
# option-argument to be concatenated to the option, eg: "-f arg" == "-farg"
while getopts "i:l:r:t:q?-:" GETOPT; do
    case ${GETOPT} in
        -)
            OPTKEY=`echo ${OPTARG} | sed -e 's/=.*//'`
            OPTARG=`echo ${OPTARG} | sed -e "s/^${OPTKEY}=\{0,1\}//"`

            # Common fragment of code to test for presence of OPTARG
            require_OPTARG() {
                if [[ -z ${OPTARG} ]]; then
                    echo "${0}: option requires an argument -- ${OPTKEY}" >&2
                    __help
                    exit 1
                fi
            }

            # Process all long option key and their values
            case ${OPTKEY} in
                imapsync)
                    require_OPTARG
                    BIN_IMAPSYNC=${OPTARG}
                    ;;
                log)
                    require_OPTARG
                    CFG_LOGFILE=${OPTARG}
                    ;;
                report)
                    require_OPTARG
                    CFG_REPORT=${OPTARG}
                    ;;
                timeout)
                    require_OPTARG
                    CFG_TIMEOUT=${OPTARG}
                    ;;

                user1)
                    require_OPTARG
                    CFG_USER1=${OPTARG}
                    ;;
                pass1)
                    require_OPTARG
                    CFG_PASS1=${OPTARG}
                    ;;
                host1)
                    require_OPTARG
                    CFG_HOST1=${OPTARG}
                    ;;
                port1)
                    require_OPTARG
                    CFG_PORT1=${OPTARG}
                    ;;

                user2)
                    require_OPTARG
                    CFG_USER2=${OPTARG}
                    ;;
                pass2)
                    require_OPTARG
                    CFG_PASS2=${OPTARG}
                    ;;
                host2)
                    require_OPTARG
                    CFG_HOST2=${OPTARG}
                    ;;
                port2)
                    require_OPTARG
                    CFG_PORT2=${OPTARG}
                    ;;

                quiet)
                    exec > /dev/null 2>&1
                    ;;
                version)
                    echo "Shell script $0 version ${VERSION}"
                    echo `bash --version | head -n 1`
                    exit
                    ;;
                help)
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
            ;;

        i)
            BIN_IMAPSYNC=${OPTARG}
            ;;
        l)
            CFG_LOGFILE=${OPTARG}
            ;;
        r)
            CFG_REPORT=${OPTARG}
            ;;
        t)
            CFG_TIMEOUT=${OPTARG}
            ;;

        q)
            exec > /dev/null 2>&1
            ;;
        ?)
            __help
            exit
            ;;
    esac
done

# Clear all options and reset the command line argument count
shift $(( OPTIND -1 ))

# Account for an option-terminator string
if [[ "${1}" = "--" ]]; then
    shift
fi

# Convert command line arguments into a list of folders
if [[ ${!#} != ${0} ]]; then
    CFG_FOLDERS=( "${@}")
fi

# Verify that imapsync command exists
if [[ ! -x ${BIN_IMAPSYNC} ]]; then
    echo "${0}: illegal configuration -- imapsync command is missing" >&2
    __help
    exit 1
fi

# Verify that the username and password are supplied for both IMAP servers
for i in 1 2; do
    user="CFG_USER${i}"
    pass="CFG_PASS${i}"
    host="CFG_HOST${i}"
    port="CFG_PORT${i}"

    # Terminate execution if user, host or port are missing
    if [[ -z ${!user} ]] || [[ -z ${!host} ]] || [[ -z ${!port} ]]; then
        echo "${0}: illegal configuration -- define all of the following:" >&2
        echo "   Server 1: username, password, hostname and port" >&2
        echo "   Server 2: username, password, hostname and port" >&2
        exit 1
    fi

    # Request the user to enter a password if it is missing
    if [[ ! ${!pass} ]] || [[ -z ${!pass} ]]; then
        read -rsp "Please enter password for ${!user}:" ${!pass}
        echo
    fi
done

# Initialise script destructor
trap __exit EXIT

#
# Primary script code
#

# Configure imapsync to rewrite old account mail address to the new one
ESC_USER1=`echo ${CFG_USER1} | sed 's/@/\\\\@/'`
ESC_USER2=`echo ${CFG_USER2} | sed 's/@/\\\\@/'`
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
ARG_IMAPSERV1="${ARG_IMAPSERV1} --host1 '${CFG_HOST1}' --port1 ${CFG_PORT1} --user1 '${CFG_USER1}' --password1 '${CFG_PASS1}"
ARG_IMAPSERV2="${ARG_IMAPSERV2} --host2 '${CFG_HOST2}' --port2 ${CFG_PORT2} --user2 '${CFG_USER2}' --password2 '${CFG_PASS2}"
ARG_IMAPSYNC="${ARG_IMAPSYNC} ${ARG_IMAPSERV1} ${ARG_IMAPSERV2} ${ARG_REWRITE}"

# Process all folders one by one
for folder in "${CFG_FOLDERS[@]}"; do
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
        echo "${BIN_IMAPSYNC} ${ARG_IMAPSYNC} ${arg_stagger}"
        until `${BIN_IMAPSYNC} ${ARG_IMAPSYNC} ${arg_stagger}`; do
            # Tell logfile what we are doing
            log ""
            log "***** NOT COMPLETE - ${folder} ${arg_stagger} *****"
            log ""

            # Initialise requested timeout
            if [ ${CFG_TIMEOUT} ]; then
                message="Sleeping for ${CFG_TIMEOUT}..."
                say "  ${message}"
                log ${message} "-n"
                sleep ${CFG_TIMEOUT}
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
exit
