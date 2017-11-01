#!/bin/bash

script='/usr/local/openvpn_as/scripts/sqlite3'
dirdbs='/usr/local/openvpn_as/etc/db'
dirbackups='/home/vb/backups'
dbs=(certs config log userprop)
namearchive=backup-$(date +%Y%m%d-%H-%M-%S).tar.gz
s3url='s3://path/to/s3/bucket'

keep_daily=7
keep_weekly=30
keep_monthly=365

month_day=`date +"%d"`
week_day=`date +"%u"`

folders=(daily weekly monthly)

for folder in "${folders[@]}"; do
        if  ! [ -d $dirbackups/$folder ]; then
                mkdir $dirbackups/$folder
        fi
done

for db in "${dbs[@]}"; do
        sudo $script $dirdbs/$db.db .dump > $dirbackups/daily/$db.db.backup
done

cd $dirbackups/daily && tar -cvf $namearchive *.db.backup

count_arhives_monthly=`find $dirbackups/monthly/ -maxdepth 1 -mtime -$month_day -type f | wc -l`
count_arhives_weekly=`find $dirbackups/weekly/ -maxdepth 1 -mtime -$week_day -type f | wc -l`

if [ -f $dirbackups/daily/$namearchive ]; then
        rm -rf $dirbackups/daily/*.db.backup
        echo "Archive is created"
        /usr/local/bin/aws s3 cp $dirbackups/daily/$namearchive $s3url
        # On first month day do
        if [ $count_arhives_monthly -lt 1 ]; then
                cp  $dirbackups/daily/$namearchive $dirbackups/monthly
        fi
        # On mondays do
        if [ $count_arhives_weekly -lt 1 ]; then
               cp  $dirbackups/daily/$namearchive $dirbackups/weekly
        fi
else
        echo 'Archive is not created'
fi

# daily
find $dirbackups/daily/ -maxdepth 1 -mtime +$keep_daily -type f -exec rm -rv {} \;

# weekly
find $dirbackups/weekly/ -maxdepth 1 -mtime +$keep_weekly -type f -exec rm -rv {} \;

# monthly
find $dirbackups/monthly/ -maxdepth 1 -mtime +$keep_monthly -type f -exec rm -rv {} \;
