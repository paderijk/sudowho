#!/bin/bash
# Version 0.4.0

SUDOERS="/etc/sudoers"

# Idenitify which sudo binary
SUDO=$(which sudo)
# Identify find binary
FIND=$(which find)

# Get a valid sudo token
$SUDO -v
EXIT_CODE=$?

# Exit if sudo token fails
if [ "$EXIT_CODE" != "0" ];
then
    echo "Error getting sudo token"
    exit 1
fi

#------ Functions

# Function to parse the sudo rules
parse_sudo_rules ()
{
    for x in $SUDO_RULES;
    do
        case $x in
        %*)
                # sudo via group
                group=$(echo $x | sed -e 's/%//g')
                for members in $(getent group $group | awk -F: '{ print $NF }' | sed -e 's/,/ /g' )
                do
                    echo -n "$HOSTNAME;group;$group;$members;"
                    echo -n $(getent passwd $members | awk -F: '{ print $5 }')
                    echo ";"$sudo_file";"
                done
            ;;
        +*)
                # sudo via a netgroup
                # getent netgroup [name]
                group=$(echo $x | sed -e 's/+//g')
                for members in $(getent netgroup $group | sed -e 's/ //g' -e 's/(,/ /g' -e 's/,)//g' | awk -F$group '{ print $NF }' )
                do
                    echo -n "$HOSTNAME;netgroup;$group;$members;"
                    echo -n "$(getent passwd $members | awk -F: '{ print $5 }')"
                    echo ";"$sudo_file";"
                done
            ;;

        *)
                # sudo via user directly configured
                echo -n "$HOSTNAME;direct;;$x;"
                echo -n $(getent passwd $x | awk -F: '{ print $5 }')
                echo ";"$sudo_file";"
            ;;
        esac
    done 
}
#------ End of functions section

# Find the relevant directory as set bij the #includedir
SUDO_INCLUDE_DIR=$($SUDO -u root cat $SUDOERS | grep '#includedir' | awk '{ print $NF }')

# Read content of the SUDO_INCLUDE_DIR to identify the filenames
# Fixing issue #1
SUDO_INCLUDE_FILES=$($SUDO -u root $FIND $SUDO_INCLUDE_DIR -type f -print)

# Parse the files
for sudo_file in $SUDOERS $SUDO_INCLUDE_FILES;
do
    SUDO_RULES=$($SUDO -u root cat $sudo_file | grep -v '^#' | grep -v "^   "| grep -v "^Defaults" | grep -v "^Host_Alias" | grep -v "^User_Alias" | grep -v "^Cmnd_Alias" | awk '{ print $1 }')
    if [ ! -z "$SUDO_RULES" ];
    then
        parse_sudo_rules |  sed -e 's/^$//g'
    fi
done


