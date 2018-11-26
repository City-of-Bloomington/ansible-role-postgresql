#!/bin/bash
#
# @license https://www.gnu.org/licenses/gpl-3.0.txt GNU/GPL, see LICENSE
BACKUP_DIR=/srv/backups/postgres

# How many days worth of tarballs to keep around
num_days_to_keep=5

#----------------------------------------------------------
# Backups
#----------------------------------------------------------
now=`date +%s`
today=`date +%F`

cd $BACKUP_DIR
sudo -u postgres pg_dumpall -c > ${today}.sql
gzip ${today}.sql

# Purge any backup tarballs that are too old
cd $BACKUP_DIR
for file in `ls`
do
	atime=`stat -c %Y $file`
	if [ $(( $now - $atime >= $num_days_to_keep*24*60*60 )) = 1 ]
	then
		rm $file
	fi
done
