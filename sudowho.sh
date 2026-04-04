#!/bin/bash
# Version 0.6.0

# Check if sudoers file is mentioned as first option
if [ -z "$1" ]; then
    SUDOERS="/etc/sudoers"
else
    SUDOERS="$1"
fi

# Identify which sudo binary
SUDO=$(which sudo)
# Identify find binary
FIND=$(which find)

# Get a valid sudo token
"$SUDO" -v
if [ $? -ne 0 ]; then
    echo "Error getting sudo token" >&2
    exit 1
fi

# Check if we can read the $SUDOERS file via sudo
"$SUDO" cat "$SUDOERS" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error reading the sudoers file: $SUDOERS" >&2
    exit 1
fi

#------ Functions

# Emit one output line: hostname;type;group;user;fullname;source_file
emit_row() {
    local _type=$1
    local _group=$2
    local _user=$3
    local _file=$4
    local _fullname
    _fullname=$(getent passwd "$_user" | awk -F: '{ print $5 }')
    echo "$HOSTNAME;$_type;$_group;$_user;${_fullname};$_file"
}

# Parse the sudo rules from a given file
parse_sudo_rules() {
    local _SUDO_RULE=$1
    local _SUDO_FILE=$2
    local x
    for x in $_SUDO_RULE; do
        case $x in
            %*)
                sudo_group "$x" "$_SUDO_FILE"
                ;;
            +*)
                sudo_netgroup "$x" "$_SUDO_FILE"
                ;;
            User_Alias*)
                echo "Warning: User_Alias not yet supported, skipping in: $_SUDO_FILE" >&2
                ;;
            *)
                sudo_direct "$x" "$_SUDO_FILE"
                ;;
        esac
    done
}

# Parse details for a directly-configured user
sudo_direct() {
    local _input=$1
    local _file=$2
    emit_row "direct" "" "$_input" "$_file"
}

# Parse details for a group-based grant
sudo_group() {
    local _input=$1
    local _file=$2
    local _group
    _group=$(echo "$_input" | sed -e 's/%//g')
    local member
    local members
    members=$(getent group "$_group" | awk -F: '{ print $NF }' | tr ',' ' ')
    if [ -z "$members" ]; then
        echo "Warning: group '$_group' not found or has no members, skipping" >&2
        return
    fi
    for member in $members; do
        emit_row "group" "$_group" "$member" "$_file"
    done
}

# Parse details for a netgroup-based grant
sudo_netgroup() {
    local _input=$1
    local _file=$2
    local _group
    _group=$(echo "$_input" | sed -e 's/+//g')
    local member
    local members
    members=$(getent netgroup "$_group" \
        | sed -e 's/ //g' -e 's/(,/ /g' -e 's/,)//g' \
        | awk -F"$_group" '{ print $NF }')
    if [ -z "$members" ]; then
        echo "Warning: netgroup '$_group' not found or has no members, skipping" >&2
        return
    fi
    for member in $members; do
        emit_row "netgroup" "$_group" "$member" "$_file"
    done
}

#------ End of functions section

# Find the relevant directory as set by the #includedir directive
SUDO_INCLUDE_DIR=$("$SUDO" -u root cat "$SUDOERS" | grep '^#includedir' | awk '{ print $NF }')

# Build list of include files; skip find if no includedir was configured
SUDO_INCLUDE_FILES=()
if [ -n "$SUDO_INCLUDE_DIR" ]; then
    while IFS= read -r -d '' f; do
        SUDO_INCLUDE_FILES+=("$f")
    done < <("$SUDO" -u root "$FIND" "$SUDO_INCLUDE_DIR" -type f -print0)
fi

# Parse all files
for sudo_file in "$SUDOERS" "${SUDO_INCLUDE_FILES[@]}"; do
    SUDO_RULES=$("$SUDO" -u root cat "$sudo_file" \
        | grep -v '^#' \
        | grep -v '^[[:space:]]' \
        | grep -v '^Defaults' \
        | grep -v '^Host_Alias' \
        | grep -v '^Cmnd_Alias' \
        | grep -v '^$' \
        | awk '{ print $1 }')
    if [ -n "$SUDO_RULES" ]; then
        parse_sudo_rules "$SUDO_RULES" "$sudo_file"
    fi
done
