# sudowho Changelog

## sudowho 0.5.0 (2023-09-26)
### Added:
 - Put more things into functions to become more future proof
 - Dummy function to parse `User_Alias` in the future
 - Allow to parse an alternative file via the command line as first option `sudowho.sh /etc/alternative-sudoers`
 - Check if the `/etc/sudoers` file or its alternative are readible via the `sudo` command

## sudowho 0.4.0 (2023-09-26)
### Added:
 - Rules for `sudo` in the documentation to have least privileged access ([#2][i2])
 - Added hostname to the output in the first field, in order to make data analytics across multiple systems easier
### Fixed
 - Modified the filter so `Cmnd_Alias` is filtered out, in 0.3.0 was the `n` forgotten (`Cmd_Alias`)

## sudowho 0.3.0 (2023-09-26)
### Added:
 - Added to the output where the rule sits
 - Remove lines like `Cmd_Alias`, `Host_Alias`, `User_Alias` from being parsed
 - Started to use functions
 - Parse from `/etc/sudoers` file the `#includedir` value
 - Output examples
### Fixed
 - RHEL7 issue fixed ([#1][i1])

## sudowho 0.2.0 (2023-09-25)
### Added:
 - Documentation on the output
 - support for netgroups
 - Datadictionary for the output
 - Usergroup for direct user is now empty

## sudowho 0.1.0 (2023-09-25)
### Added:
 - Parsing users and show display name 
 - Parsing members of groups
 - Output in Semicolon (`;`) seperate value format
 - Use sudo to read files for least privileged appraoch 

---------------------------------------------------------------------------------
[i1]: https://github.com/paderijk/sudowho/issues/1
[i2]: https://github.com/paderijk/sudowho/issues/2
