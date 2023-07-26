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
Source;Groupname;User-id;Name give to the user;file-location
```

Current options of the `source` are:
 * `direct` - Username is direct listed in sudoers
 * `group` - User is member of a group
 * `netgroup` - User is member of a netgroup

Groupname options:
 * empty value - User is directly configured
 * value - User is member of this group

### Example
```
direct;;pieter;Pieter de Rijk;/etc/sudoers
```
User `pieter` has been directly configured in the `/etc/sudoers` file.

```
group;support;john;John Glenney;/etc/sudoers.d/it-admins
```
The user `john` has been configured in the `/etc/sudoers.d/it-admins` file, because he is member of the group `support`.

```
netgroup;glbadmins;remco;Remco Dude;/etc/sudoers.d/glb-admins
```
The user `remco` has been configured in the `/etc/sudoers.d/glb-admins` file, because he is member of the netgroup `glbadmins`.
