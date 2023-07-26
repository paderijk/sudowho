# sudowho Changelog

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
 - Output in Semicolon (;) seperate value format
 - Use sudo to read files for least privileged appraoch 

---------------------------------------------------------------------------------
[i1]: https://github.com/paderijk/sudowho/issues/1
