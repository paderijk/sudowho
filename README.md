# sudowho 

## About

This is a script that allows you to identify which users are configured to allow actions via sudo.

## Prerequisites

* At least sudo access to read using cat /etc/sudoers and the directories configured in that file

## Run it

```bash
bash sudowho.sh
```

## Output

Output will be seperating the values in a semicolumn.

```
Source;Groupname;User-id;Name give to the user
```

Current options of the `source` are:
 * `direct` - Username is direct listed in sudoers
 * `group` - User is member of a group
 * `netgroup` - User is member of a netgroup

Groupname options:
 * empty value - User is directly configured
 * value - User is member of this group
