#!/bin/bash
# Version 0.1.0

SUDOERS="/etc/sudoers"
SUDO_DIR="/etc/sudoers.d/"

# Idenitify which sudo binary
SUDO=$(which sudo)

# Get a valid sudo token
$SUDO -v
EXIT_CODE=$?

# Exit if sudo token fails
if [ "$EXIT_CODE" != "0" ];
then
    echo "Error getting sudo token"
    exit 1
fi

SUDO_RULES=$($SUDO -u root cat $SUDOERS $SUDO_DIR/* |  egrep '.*=\(.*:.*' | awk '{ print $1 }')

for x in $SUDO_RULES;
do
    case $x in
        %*)
            # sudo via group
            group=$(echo $x | sed -e 's/%//g')
            for members in $(getent group $group | awk -F: '{ print $NF }' | sed -e 's/,/ /g' )
            do
                echo -n "Group;$group;$members;"
                getent passwd $members | awk -F: '{ print $5 }'
            done
        ;;
        *)
            echo -n "Direct;user;$x;"
            getent passwd $x | awk -F: '{ print $5 }'
        ;;
    esac
done
