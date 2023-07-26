#!/bin/bash
# Version 0.5.0

# Check if sudoers file is mentioned as first option
if [ -z "$1" ];
then
    # If empty default behaviour
    SUDOERS="/etc/sudoers"
else
    SUDOERS="$1"
fi

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

# Check if we can sudo cat the $SUDOERS file
$SUDO cat $SUDOERS > /dev/null 2> /dev/null
EXIT_CODE=$?
# Exit if sudo token fails
if [ "$EXIT_CODE" != "0" ];
then
    echo "Error reading the $SUDOERS file via sudo"
    exit 1
fi

#------ Functions
# Function to parse the sudo rules
parse_sudo_rules ()
{
    local _SUDO_FILE=$2
    local _SUDO_RULE=$1
    for x in $_SUDO_RULE;
    do
        case $x in
        %*)
            # % sign indicates a group
            sudo_group $x
           ;;
        +*)
            # + sign indicates a netgroup
            sudo_netgroup $x
           ;;
        User_Alias*)
           # Parse User_Alias
           # Note this is not implemented yet
           sudo_useralias "$x" "$_SUDO_FILE"
           ;;
        *)
            # sudo via user directly configured
            sudo_direct $x
            ;;
        esac
    done
}

# Parse details direct user
sudo_direct ()
{
    local _input=$1
    # sudo via user directly configured
    echo -n "$HOSTNAME;direct;;$_input;"
    echo -n $(getent passwd $_input | awk -F: '{ print $5 }')
    echo ";"$sudo_file";"
}

# Parse details group user
sudo_group ()
{
    # sudo via group
    local _input=$1
    local _group=$(echo $_input | sed -e 's/%//g')
    for members in $(getent group $_group | awk -F: '{ print $NF }' | sed -e 's/,/ /g' )
    do
        echo -n "$HOSTNAME;group;$_group;$members;"
        echo -n $(getent passwd $members | awk -F: '{ print $5 }')
        echo ";"$sudo_file";"
    done
}

# Parse details netgroup user
sudo_netgroup()
{
    # sudo via a netgroup
    # getent netgroup [name]
    local _input=$1
    group=$(echo $_input | sed -e 's/+//g')
    for members in $(getent netgroup $group | sed -e 's/ //g' -e 's/(,/ /g' -e 's/,)//g' | awk -F$group '{ print $NF }' )
    do
        echo -n "$HOSTNAME;netgroup;$group;$members;"
        echo -n "$(getent passwd $members | awk -F: '{ print $5 }')"
        echo ";"$sudo_file";"
    done
}

# Parse User Alias Details
sudo_useralias()
{
    # To be written
    # Doing nothing at this stage
    echo 2> /dev/null > /dev/null
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
    SUDO_RULES=$($SUDO -u root cat $sudo_file | grep -v '^#' | grep -v "^   "| grep -v "^Defaults" | grep -v "^Host_Alias" |  grep -v "^Cmnd_Alias" | awk '{ print $1 }')
    if [ ! -z "$SUDO_RULES" ];
    then
        parse_sudo_rules "$SUDO_RULES" "$sudo_file" |  sed -e 's/^$//g'
    fi
done


