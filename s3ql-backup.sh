#!/bin/bash

PIC_DIR_TO_BACKUP=/home/SHARE/Pictures/
BUCKET_NAME=schuit-bucket
MOUNT_DIR=/mnt/schuit-bucket

PIC_BACKUP_CMD="rsync -a --delete --verbose /home/SHARE/Pictures/ /mnt/schuit-bucket/Pictures/"
HOME_MOVIE_BACKUP_CMD="rsync -a --delete --verbose /home/SHARE/Video/Home /mnt/schuit-bucket/Video/"

# This will mount and store the output to a variable
MOUNT_CMD=`mount.s3ql --cachesize 1024000 s3://schuit-bucket /mnt/schuit-bucket 2>&1` 
#eval $MOUNT_CMD

if [[ $MOUNT_CMD == *fsck* ]] ; then
	MOUNT_VALUE="fsck was needed this time"
	echo "uh oh - running fsck on s3ql storage"
	#umount $MOUNT_DIR
	fsck.s3ql s3://$BUCKET_NAME
	echo "s3ql FS is now clean, proceeding to backup"
	# mount bucket
	mount.s3ql --cachesize 1024000 s3://$BUCKET_NAME $MOUNT_DIR
	PIC_DIR_TO_BACKUP_OUTPUT=`$PIC_BACKUP_CMD`			
	HOME_MOVIE_BACKUP_CMD_OUTPUT=`$HOME_MOVIE_BACKUP_CMD`

elif [[ `$MOUNT_CMD | grep 'BusyError: database is locked'` ]] ; then
	MOUNT_VALUE="the db was locked"
	killall mount.s3ql && fsck.s3ql s3://$BUCKET_NAME
	# mount bucket
	mount.s3ql --cachesize 1024000 s3://$BUCKET_NAME $MOUNT_DIR
	PIC_DIR_TO_BACKUP_OUTPUT=`$PIC_BACKUP_CMD`
	HOME_MOVIE_BACKUP_CMD_OUTPUT=`$HOME_MOVIE_BACKUP_CMD`

else
	MOUNT_VALUE="everything went as expected"
	echo "s3ql FS is looking good, proceeding to backup"
	# mount bucket
	mount.s3ql --cachesize 1024000 s3://$BUCKET_NAME $MOUNT_DIR
	PIC_DIR_TO_BACKUP_OUTPUT=`$PIC_BACKUP_CMD`
	HOME_MOVIE_BACKUP_CMD_OUTPUT=`$HOME_MOVIE_BACKUP_CMD`
	echo "Picture and Home Movie directory is backed up!"
fi

# unmount the S3 bucket
umount $MOUNT_DIR
echo "bucket unmounted!  K BYE!"
# Below is an example to use gmail to give you a quick report
# TODO: Make this a part of arguments
# sendEmail -v -f riley.schuit@gmail.com -s smtp.gmail.com:587 -xu joetheplummer@gmail.com -xp supersecretpassword -t "mymom@gmail.com; mydad@gmail.com" -o tls=yes -u Weekly Backup Report `date +"%m-%d-%Y"` -m "During this backup, $MOUNT_VALUE.  The email sent concludes that the task completed. \n\n Here is a list of the changes to the backup: \n From the Picture backup: $PIC_DIR_TO_BACKUP_OUTPUT \n\n From the Video Backup: $HOME_MOVIE_BACKUP_CMD_OUTPUT" 
