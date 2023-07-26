# sudowho

## About

This is a script that allows you to identify which users are configured to allow actions via sudo.

## Prerequisites

* `sudo` access to read using `cat /etc/sudoers` and the directories configured in the file with `#includedir`, which is typically `/etc/sudoers.d`.
* `find` access to identify the files in the `#includedir`.

### sudoers rule

In this example we asume the user is `sudowho`, modify the example to meet your settings and have least privileged access.

```
# Commands run by sudowho
Cmnd_Alias SUDOWHO_CMD = /bin/cat /etc/sudoers, /bin/cat /etc/sudoers.d/*, /usr/bin/find /etc/sudoers.d -type f -print
sudowho ALL=(ALL:ALL) SUDOWHO_CMD
```

## Run it

```bash
bash sudowho.sh
```

## Output

Output will be seperating the values in a semicolumn.

```
Hostname;Source;Groupname;User-id;Name give to the user;file-location
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
srv01;direct;;pieter;Pieter de Rijk;/etc/sudoers
```
User `pieter` has been directly configured in the `/etc/sudoers` file on server named `srv01`..

```
webserver;group;support;john;John Glenney;/etc/sudoers.d/it-admins
```
The user `john` has been configured in the `/etc/sudoers.d/it-admins` file, because he is member of the group `support` on the server named `webserver`.

```
foobar;netgroup;glbadmins;remco;Remco Dude;/etc/sudoers.d/glb-admins
```
The user `remco` has been configured in the `/etc/sudoers.d/glb-admins` file, because he is member of the netgroup `glbadmins` on the server named `foobar`.
