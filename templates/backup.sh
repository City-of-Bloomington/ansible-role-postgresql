#!/bin/bash
#
# @license https://www.gnu.org/licenses/gpl-3.0.txt GNU/GPL, see LICENSE
BACKUP_DIR=/srv/backups

# How many days worth of tarballs to keep around
num_days_to_keep=5
now=`date +%s`
today=`date +%F`
year_month=`date +%Y/%m`
host=`hostname`

#----------------------------------------------------------
# Create a binary backup for each database
#----------------------------------------------------------
[ ! -d $BACKUP_DIR/postgres ] && mkdir $BACKUP_DIR/postgres

cd $BACKUP_DIR/postgres
sudo -u postgres pg_dumpall -g > roles.sql

databases=$(sudo -u postgres psql -Xtc "select datname from pg_database where datistemplate=false")
for database in $databases
do
	if [ ! $database = postgres ]; then
        dir="/srv/backups/$database"
        [ -d $dir ] || mkdir $dir
        [ -f $dir/$today.dump ] && rm $dir/$today.dump

        cd $dir
        for file in `ls`
        do
            atime=`stat -c %Y $file`
            if [ $(( $now - $atime >= $num_days_to_keep*24*60*60 )) = 1 ]
            then
                rm $file
            fi
        done

        sudo -u postgres pg_dump -F c $database > $today.dump

        # Copy file to remote backup server
        remote_dir={{ postgresql_backup.path }}/$host/$database/$year_month
        ssh -n -i /root/.ssh/{{ postgresql_backup.user }} {{ postgresql_backup.user }}@{{ postgresql_backup.host }} "mkdir -p $remote_dir"
        scp -i /root/.ssh/{{ postgresql_backup.user }} $today.dump {{ postgresql_backup.user }}@{{ postgresql_backup.host }}:$remote_dir
    fi
done
