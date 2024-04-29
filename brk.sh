#!/usr/bin/env bash
#
# Name    : Backup and Restore of Keyrings
# Version : 1.0.0
# Author  : Radek Valášek
# Sourcee : https://github.com/reddy75/brk
# Contact : https://github.com/reddy75/brk/issues
# License : GPL3
#
# Copyright (C) 2024  Radek Valášek
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANT ABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
########################################################################
#
# Description : --------------------------------------------------------
#
# Purpose of bash script is to create backup and or restore of your keyring
# directory. Backup creating tar archives of whole keyring directory.
# Restore is interactive. Script also ensure clean old backups and left
# latest one.  
#
# [!IMPORTANT]
# Path to the keyrings is hardcoded and points to the directory:
# $HOME/.local/share/keyrings
# If your system is different setup, you have to modify line 99
# according to. The line is following:  
# export HOME_KEYRINGS=$HOME/.local/share/keyrings
#
#
# Installation : -------------------------------------------------------
#
# Installation require privileged rights of user.
# In terminal go to the directory you downloaded script, setup executable
# flags and call installation itself:
# cd /<path to downloaded script>
# chmod a+x brk.sh
# ./brk.sh --install
#
# Once successfully installed, in system will be available new following
# commands:
# - backup-keyrings
# - restore-keyrings
# - clean-backup-keyrings
#
#
# Uninstallation : -----------------------------------------------------
#
# Uninstallation of script require privileged rights of user.
# In terminal run any of available command of script with an argument
# -u or --uninstall, for example:
# backup-keyrings -u
# 
# This ensure script and commands will be removed from system.
# 
#
# Backup of keyrings : -------------------------------------------------
#
# In terminal execute:
# backup-keyrings
#
# This create compressed tar archive of whole keyring directory.
#
#
# Restore of keyring(s) : ----------------------------------------------
#
# In terminal execute:
# restore-keyrings
#
# This check all available backups of keyrings and offer which one do you
# need to restore. Restore is interactive, you will be prompted for:
# 1. backup from where you need to restore
# 2. content of backup you need to restore
#
# If you need restore all content from latest backup simply hit enter twice.
#
#
# Clean backup of keyrings : -------------------------------------------
#
# In terminal execute:
# clean-backup-keyrings
#
# Purpose of the command is to remove unnecessary old backups which is
# usually no longer required. The command only ask if you really need to
# clean old backups and left only latest one in system.


export HOME_KEYRINGS=$HOME/.local/share/keyrings
export SCRIPT_VERSION=$(cat ${BASH_SOURCE[0]} | grep -i version | head -n 1 | cut -d ':' -f 2- | sed -e 's/^[ ]*//')

case $1 in
  -i|--install)
    if [[ $UID -gt 0 ]];
    then
      sudo ${BASH_SOURCE[0]} -i
      RESULT=$?
      echo
      [[ $RESULT -eq 0 ]] \
        && echo "Installation of Script Backup and Restore Keyrings compelted successfully." \
        || echo "Installation of Script Backup and Restore Keyrings failed!"
      exit $RESULT
    fi
    # 1. We need uninstall previously installed script
    ${BASH_SOURCE[0]} -u
    RESULT=$?
    # 2. Then we create new installation
    # 2.a. Install basic script
    TARGET_DIR=/opt/Scripts/Utilities
    TARGET_FILE=$TARGET_DIR/brk.sh
    [[ ! -d $TARGET_DIR ]] && mkdir -p $TARGET_DIR || :
    touch $TARGET_FILE
    [[ $? -gt 0 ]] && RESULT=$? || :
    chmod 755 $TARGET_FILE
    [[ $? -gt 0 ]] && RESULT=$? || :
    cat ${BASH_SOURCE[0]} >> $TARGET_FILE
    [[ $? -gt 0 ]] && RESULT=$? || :
    # 2.b. Create symlinks
    TARGET_DIR=/usr/bin
    for TARGET in backup restore clean-backup;
    do
      ln -s $TARGET_FILE $TARGET_DIR/$TARGET-keyrings
      CRESULT=$?
      [[ $CRESULT -gt 0 ]] && RESULT=$? || :
      [[ $CRESULT -eq 0 ]] && printf "%-22s - installed successfully.\n" "$TARGET-keyrings" || :
    done
    exit $RESULT
    ;;
  -u|--uninstall)
    if [[ $UID -gt 0 ]];
    then
      sudo ${BASH_SOURCE[0]} -u
      RESULT=$?
      [[ $RESULT -eq 0 ]] \
        && echo "Uninstallation of Script Backup and Restore Keyrings compelted successfully." \
        || echo "Uninstallation of Script Backup and Restore Keyrings failed!"
      exit $RESULT
    fi
    # 1. Remove simlinks
    RESULT=0
    TARGET_DIR=/usr/bin
    for TARGET in backup restore clean-backup;
    do
      TARGET_LINK=$TARGET_DIR/$TARGET-keyrings
      [[ -f $TARGET_LINK ]] && rm -f $TARGET_LINK || :
      [[ $? -gt 0 ]] && RESULT=$? || :
    done
    # 2. Remove from /opt/Scripts/Utilities
    TARGET_DIR=/opt/Scripts/Utilities
    TARGET_FILE=$TARGET_DIR/brk.sh
    [[ -f $TARGET_FILE ]] && rm -f $TARGET_FILE || :
    [[ $? -gt 0 ]] && RESULT=$? || :
    exit $RESULT
    ;;
  -h|--help)
    cat - << EOF

Backup/Restore Keyrings version $SCRIPT_VERSION
========================================================================
Usage:

backup-keyrings
- Create a backup of keyrings.

restore-keyrings
- Restore a keyrings from a backup. Restore is interactive.

clean-backup-keyrings
- Clean/remove old backups of keyrings, latest one will remain in system.

EOF
    exit
    ;;
esac

FUNCTION=$(echo ${BASH_SOURCE[0]} | rev | cut -d '/' -f 1 | rev)

cat - << EOF
Backup/Restore Keyrings version $SCRIPT_VERSION
- For help of usage put argument -h or --help.

EOF

export BACKUP_KEYRINGS=$HOME_KEYRINGS.backup
export BACKUP_TIME=$(date '+%Y-%m-%dT%H-%M-%S-%s')

function_backup(){
  cd $HOME_KEYRINGS
  [[ ! -d $BACKUP_KEYRINGS ]] && mkdir $BACKUP_KEYRINGS || :
  BACKUP_TARGZ=$BACKUP_KEYRINGS/$BACKUP_TIME.tar.gz
  echo "Creating backup : $BACKUP_TARGZ"
  tar -czvf $BACKUP_TARGZ .
  echo
  echo "Last backups :"
  cd $BACKUP_KEYRINGS
  ls *.tar.gz | sort
  echo
  echo "Backup of keyrings completed successfully"
}

function_restore(){
  cd $BACKUP_KEYRINGS
  echo "Following backups exists:"
  ls *.tar.gz | sort
  echo
  echo "Entering empty backup name will restore latest backup."
  read -p "Enter backup to be restored : " BACKUP_FILE
  if [[ -z "$BACKUP_FILE" ]];
  then
    LAST_BACKUP=$(ls *.tar.gz | sort | tail -n 1)
  else
    LAST_BACKUP=$BACKUP_FILE
  fi
  cd $HOME_KEYRINGS
  echo "Examining backup :$LAST_BACKUP"
  BACKUP_LIST=/tmp/.$$.backup-keyrings-list
  BACKUP_LIST2=/tmp/.$$.backup-keyrings-list2
  RESTORE_LIST=/tmp/.$$.restore-keyrings-list
  trap "rm -f $BACKUP_LIST $BACKUP_LIST2 $RESTORE_LIST" SIGHUP SIGINT SIGQUIT SIGKILL SIGTERM EXIT 0 9
  touch $BACKUP_LIST $RESTORE_LIST $BACKUP_LIST2
  tar -tzvf $BACKUP_KEYRINGS/$LAST_BACKUP >> $BACKUP_LIST
  while read -r LINE;
  do
    FILE_NAME=$(echo $LINE | sed -e 's/\.\//#/g' | cut -d '#' -f 2-)
    FILE_INFO=$(echo $LINE | sed -e 's/\.\//#/g' | cut -d '#' -f 1)
    [[ -n "$FILE_NAME" ]] \
      && printf "%-30s [%s]\n" "$FILE_NAME" "$FILE_INFO" | tee -a $BACKUP_LIST2 \
      || :
  done < <(cat $BACKUP_LIST)
  echo
  cat - << EOF
Which keyring(s) do you need to restore?
- Restore all hit enter now.
- Restore file(s) enter file name, once you finish enter empty line.

EOF
  export DONE=False
  while [[ $DONE == False ]];
  do
    read -p "Enter file name : " CONTENT
    if [[ -n "$CONTENT" ]];
    then
      grep -E ^"$CONTENT" $BACKUP_LIST2 2>/dev/null
      RESULT=$?
      if [[ $RESULT -eq 0 ]];
      then
        echo "./$CONTENT" >> $RESTORE_LIST
      else
        echo "File \"$CONTENT\" is not in backup, enter correct file name."
      fi
    else
      export DONE=True
    fi
  done
  if [[ -s $RESTORE_LIST ]];
  then
    echo ">> Restoring entered content..."
    tar -xzvf $BACKUP_KEYRINGS/$LAST_BACKUP -T $RESTORE_LIST
    RESULT=$?
  else
    echo ">> Restoring all..."
    tar -xzvf $BACKUP_KEYRINGS/$LAST_BACKUP
    RESULT=$?
  fi
  [[ $RESULT -eq 0 ]] \
    && echo "Restore completed successfully." \
    || echo "Restore failed."
  rm -f $BACKUP_LIST $RESTORE_LIST $$BACKUP_LIST2
}

function_clean(){
  cd $BACKUP_KEYRINGS
  echo "Cleaning backups, only latest will remain."
  echo "List of backups :"
  ls *.tar.gz | sort
  echo
  read -p "Do you really want to clean backups except latest one? (y/N)" CLEANME
  case $CLEANME in
    y|Y)
      LATEST_BACKUP=$(ls *.tar.gz | sort | tail -n 1)
      echo "Following backups to be removed:"
      REST_BACKUPS=$(ls *.tar.gz | sort | grep -v "$LATEST_BACKUP")
      echo $REST_BACKUPS
      rm -f $REST_BACKUPS
      echo
      echo "Backups were removed."
      ;;
    *)
      echo "All backups remain."
      ;;
  esac
}

case $FUNCTION in
  backup-keyrings)
    function_backup $@
    ;;
  restore-keyrings)
    function_restore $@
    ;;
  clean-backup-keyrings)
    function_clean
    ;;
  *)
    echo "Is the script installed properly?"
    exit 1
    ;;
esac
