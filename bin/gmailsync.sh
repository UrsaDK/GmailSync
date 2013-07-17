#!/bin/bash

# Define parameters for the 'From' account 
USER1=''
PASS1=''
HOST1='imap.gmail.com'
PORT1='993'
OPT1='--ssl1 --authmech1 LOGIN --split1 100'

# Define parameters for the 'To' account
USER2=''
PASS2=''
HOST2='imap.gmail.com'
PORT2='993'
OPT2='--ssl2 --authmech2 LOGIN --split2 100'

# Configure global imapsync parameters
SYNCMD='imapsync --dry --syncinternaldates --skipsize --useheader "Date" --useheader "Message-ID"'
LOGFILE='imapsync.log'
TIMEOUT='10'

# An email address to which to sent current activity log
REPORT=''

# List default folders that you would like transfered 
FOLDERS=( 'INBOX' 'All Mail' 'Bin' 'Drafts' 'Starred' 'Sent Mail' )

#################################################
## You shouldn't need to modify anything below ##
##  If you do so, then do it at your own risk  ##
#################################################

# Escape email address so we can use it in regex
USER1ESC=`echo ${USER1} | sed 's/@/\\\\@/'`
USER2ESC=`echo ${USER2} | sed 's/@/\\\\@/'`

# Split transfer by age and add header rewrite rules
TIMES=( '--minage 1090' '--maxage 1091 --minage 999' '--maxage 1000 --minage 908' '--maxage 909 --minage 817' '--maxage 818 --minage 726' '--maxage 727 --minage 635' '--maxage 636 --minage 544' '--maxage 545 --minage 453' '--maxage 454 --minage 362' '--maxage 363 --minage 271' '--maxage 272 --minage 180' '--maxage 181 --minage 89' '--maxage 90' )
REGEX=( "s/Delivered-To: ${USER1ESC}/Delivered-To: ${USER2ESC}/gi" "s/<${USER1ESC}>/<${USER2ESC}>/gi" "s/^((To|From|Cc|Bcc):.*)${USER1ESC}(.*)$/\$1${USER2ESC}\$3/gim" 's/Subject:(\s*)\n/Subject: (no--subject)$1\n/ig' 's/Subject: ([Rr][Ee]):(\s*)\n/Subject: $1: (no--subject)$2\n/gi' )

# Initialise a new logfile
echo "**** START ****" > $LOGFILE

# Override default folders
if [ "$@" ]; then
    FOLDERS=( "$@" )
fi

# Extend option strings with extra params
OPT1="${OPT1} --host1 '${HOST1}' --port1 ${PORT1} --user1 '${USER1}' --password1 '${PASS1}'"
OPT2="${OPT2} --host2 '${HOST2}' --port2 ${PORT2} --user2 '${USER2}' --password2 '${PASS2}'"

# Consolidate message rewrtite rules
for RULE in "${REGEX[@]}"; do
    RULES="${RULES} --regexmess '${RULE}'"
done

# Process all folders one by one
for FOLDER in "${FOLDERS[@]}"; do
    # Tell user what we are doing
    if [ -z ${REPORT} ]; then
        echo "Processing folder: ${FOLDER}"
    fi

    # Process message chunks in folders 
    for TIME in "${TIMES[@]}"; do
        # Tell user what we are doing
        if [ -z ${REPORT} ]; then
            echo "  Retrieving time period : ${TIME}"
        fi

        # Tell logfile what we are doing
        echo "" >> $LOGFILE
        echo "*** $FOLDER $TIME ***" >> $LOGFILE
        echo "" >> $LOGFILE

        until eval "${SYNCMD} ${OPT1} ${OPT2} --include '${FOLDER}' ${TIME} ${RULES} >> $LOGFILE 2>&1"; do
            # Tell logfile what we are doing
            echo "" >> $LOGFILE
            echo "***** NOT COMPLETE - $FOLDER $TIME *****" >> $LOGFILE
            echo "" >> $LOGFILE
           
            # Send action report to email address
            if [ ${REPORT} ]; then
                echo "Emailing result to ${REPORT}" >> $LOGFILE
                tail -100 $LOGFILE | mail -s "Imapsync Restarting for $FOLDER $TIME" "user@domain.com"
            fi

            # Initialise requested timeout
            if [ ${TIMEOUT} ]; then
                MSG="Sleeping for ${TIMEOUT}..."

                # Tell user what is going on
                if [ -z ${REPORT} ]; then
                    echo "  ${MSG}"
                fi

                echo -n ${MSG} >> $LOGFILE
                sleep ${TIMEOUT}
            fi
            
            echo "Done." >> $LOGFILE
        done

        # Tell logfile what we are doing
        echo "" >> $LOGFILE
        echo "***** COMPLETE - $FOLDER $TIME*****" >> $LOGFILE
        echo "" >> $LOGFILE

        # Send action report to email address
        if [ ${REPORT} ]; then
            echo "Emailing result to ${REPORT}" >> $LOGFILE
            tail -100 $LOGFILE | mail -s "Imapsync Complete for $FOLDER $TIME" "user@domain.com"
        fi
    done
done
echo "**** DONE ****" >> $LOGFILE

# Send action report to email address
if [ ${REPORT} ]; then
    echo "Emailing result to ${REPORT}" >> $LOGFILE
    tail -100 $LOGFILE | mail -s "Imapsync Complete" -c "user@domain.com"
fi

echo "Finished"
