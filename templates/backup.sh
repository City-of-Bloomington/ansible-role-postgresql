#!/bin/bash
#
# @license https://www.gnu.org/licenses/gpl-3.0.txt GNU/GPL, see LICENSE
BACKUP_DIR=/srv/backups/postgres

# How many days worth of tarballs to keep around
num_days_to_keep=5
now=`date +%s`
today=`date +%F`

#----------------------------------------------------------
# Create a binary backup for each database
#----------------------------------------------------------
[ ! -d $BACKUP_DIR/$today ] && mkdir $BACKUP_DIR/$today

cd $BACKUP_DIR/$today
sudo -u postgres pg_dumpall -g > roles.sql

databases=$(sudo -u postgres psql -Xtc "select datname from pg_database where datistemplate=false")
for d in $databases
do
    if [ ! $d = postgres ]; then
        sudo -u postgres pg_dump -F c $d > $d.dump
    fi
done
cd ..
tar czvf $today.tar.gz $today
rm -Rf $today

#----------------------------------------------------------
# Purge any backup tarballs that are too old
#----------------------------------------------------------
cd $BACKUP_DIR
for file in `ls`
do
	atime=`stat -c %Y $file`
	if [ $(( $now - $atime >= $num_days_to_keep*24*60*60 )) = 1 ]
	then
		rm $file
	fi
done
