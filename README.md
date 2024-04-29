# Backup and Restore of Keyrings

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANT ABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.


## Description

Purpose of bash script is to create backup and or restore of your keyring
directory. Backup creating tar archives of whole keyring directory.
Restore is interactive. Script also ensure clean old backups and left
latest one.

[!IMPORTANT]  
Path to the keyrings is hardcoded and points to the directory:  
`$HOME/.local/share/keyrings`

If your system is different setup, you have to modify line 99
according to. The line is following:  
`export HOME_KEYRINGS=$HOME/.local/share/keyrings`


## Installation

Installation require privileged rights of user.  
In terminal go to the directory you downloaded script, setup executable
flags and call installation itself:  
`cd /<path to downloaded script>`  
`chmod a+x brk.sh`  
`./brk.sh --install`

Once successfully installed, in system will be available new following
commands:  
- `backup-keyrings`  
- `restore-keyrings`  
- `clean-backup-keyrings`
  

## Uninstallation

Uninstallation of script require privileged rights of user.
In terminal run any of available command of script with an argument
`-u` or `--uninstall`, for example:  
`backup-keyrings -u`

This ensure script and commands will be removed from system.


## Backup of keyrings

In terminal execute:  
`backup-keyrings`

This create compressed tar archive of whole keyring directory.


## Restore of keyring(s)

In terminal execute:  
`restore-keyrings`

This check all available backups of keyrings and offer which one do you
need to restore. Restore is interactive, you will be prompted for:  
1. backup from where you need to restore
2. content of backup you need to restore

If you need restore all content from latest backup simply hit enter twice.


## Clean backups of keyrings

In terminal execute:  
`clean-backup-keyrings`

Purpose of the command is to remove unnecessary old backups which is
usually no longer required. The command only ask if you really need to
clean old backups and left only latest one in system.
