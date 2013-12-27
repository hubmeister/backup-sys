#!/usr/bin/perl
#
# backup-sys.pl
#
# Author: Dirck Copeland
# Date: 12/26/2013
#
# License: GPL v3
#
# Puropse:
# To backup files on a linux system with perl installed. The
# system being backed up is my-system and the system that
# the backups are being copied to is my-backup-system. Change
# those two names to your respective systems.
#
# The script assumes the directory /data/my-system/backup
# already exists. Obviously the backup directory should
# be in a different location (directory) than the files
# being backed up otherwise you will get into an endless
# recursive loop of copying files and that will not be good. ;)

#
# create time variables
#
use POSIX qw(strftime);
$my_year_month_day = strftime("%Y_%m_%d", localtime());
$my_year = strftime("%Y", localtime());

#
# Open the log file
#
open(LOG_FILE,">>/data/copy-log-file.txt") || die "Can't open copy-log-file.txt:$!\n";

#################################################################
# Create/Open backup log file
#################################################################
system('ls /data/my-system/backup/`date \'+%Y\'`');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "Directory does not exist...creating year directory in /data/my-system/backup/$my_year to copy backup file to...\n";
        printf "creating directory /data/my-system/backup/$my_year\n";
        system('mkdir /data/my-system/backup/`date \'+%Y\'`');
	open(LOG_FILE,">>/data/my-system/backup/$my_year/copy-log-file.txt") || die "Can't open copy.txt:$!\n";
} else {
	open(LOG_FILE,">>/data/my-system/backup/$my_year/copy-log-file.txt") || die "Can't open copy.txt:$!\n";
}

##################################################################
# Backup my-system
##################################################################
#*
#* remove old instance of backup
#*
system('rm -rf /data/my-system/backup/`date \'+%Y\'`/all');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "error:removing backup directory /data/my-system/backup/$my_year/all\n";
} else {
        printf LOG_FILE "removed /data/my-system/backup/$my_year/all backup directory\n";
}
#*
#* re-create backup directory structure
#*
system('mkdir /data/my-system/backup/`date \'+%Y\'`/all');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "error:creating new directory /data/my-system/backup/$my_year/all\n";
} else {
        printf LOG_FILE "created new directory /data/my-system/backup/$my_year/all\n";
}

#*
#* copy user1 home directory to /data/my-system/backup/$my_year/all
#*
system('cp -rp /home/user1 /data/my-system/backup/`date \'+%Y\'`/all');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "error:copying user1 home directory to backup directory /data/my-system/backup/$my_year/all\n";
} else {
        printf LOG_FILE "copied user1 directory to backup directory /data/my-system/backup/$my_year/all...\n";
}

#*
#* copy dir home directory to /data/my-system/backup/$my_year/all
#*
system('cp -rp /home/user1 /data/my-system/backup/`date \'+%Y\'`/all');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "error:copying user1 home directory to backup directory /data/my-system/backup/$my_year/all\n";
} else {
        printf LOG_FILE "copied user1 directory to backup directory /data/my-system/backup/$my_year/all...\n";
}

#*
#* tar user1 tmp directory to /data/my-system/backup/$my_year/my-system.backup.$my_year_month_day
#*
system('tar cf /data/my-system/backup/`date \'+%Y\'`/my-system.backup.`date \'+20%y_%m_%d\'`.tar /data/my-system/backup/`date \'+%Y\'`/all');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "error:tarring user1 home directory to backup file /data/my-system/backup/$my_year/my-system.backup.$my_year_month_day.tar\n";
} else {
        printf LOG_FILE "tarred user1 backup file to backup directory /data/my-system/backup/$my_year/my-system.backup.$my_year_month_day.tar\n";
}

#*
#* gzip backup file to /data/my-system/backup/$my_year/my-system.backup.$my_year_month_day.tar.gz
#* gzip /data/my-system/backup/2010/my-system.backup.2010_09_22.tar.gz
#*
system('gzip /data/my-system/backup/`date \'+%Y\'`/my-system.backup.`date \'+20%y_%m_%d\'`.tar');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "error:gzipping  backup file /data/my-system/backup/$my_year/my-system.backup.$my_year_month_day.tar.gz\n";
} else {
        printf LOG_FILE "gzipped  backup file to backup directory /data/my-system/backup/$my_year/\n";
}

###################################################################
# Copy the backup file to my-backup-system
###################################################################
system('ssh user1@my-backup-system ls /data/my-system/backup/`date \'+%Y\'`');
if ($? > 0) { # if return code is indicates error issuing command
        printf LOG_FILE "error:copying to file my-backup-system\n";
        printf "error: listing directory /data/my-system/backup/$my_year\n";
        printf "creating directory /data/my-system/backup/$my_year ...\n";
        system('ssh user1@my-backup-system mkdir /data/my-system/backup/`date \'+%Y\'`');
        system('/usr/bin/scp /data/my-system/backup/`date \'+%Y\'`/my-system.backup.`date \'+20%y_%m_%d\'`.tar.gz user1@my-backup-system:/data/my-system/backup/`date \'+20%y\'`/my-system.backup.`date \'+20%y_%m_%d\'`.tar.gz');
        system('/bin/echo "Backup file my-system.backup.`date \'+20%y_%m_%d\'`.tar.gz failed to be copied to my-backup-system or new directory was created." >> /home/user1/status/dns-status-my-system');
        system('/bin/echo "Note: If you continully see the above message the backups are likley failing to be copied to my-backup-system otherwise its probabaly a new year and the directory just needed to be created." >> /home/user1/status/dns-status-my-system');
} else {
        printf LOG_FILE "sucess: listing directory /data/my-system/backup/$my_year\n";
        printf "success: listing directory /data/my-system/backup/$my_year\n";
        system('/usr/bin/scp /data/my-system/backup/`date \'+%Y\'`/my-system.backup.`date \'+20%y_%m_%d\'`.tar.gz user1@my-backup-system:/data/my-system/backup/`date \'+20%y\'`/my-system.backup.`date \'+20%y_%m_%d\'`.tar.gz');
        printf "success: copying backup file /data/my-system/backup/$my_year\n";
        system('/bin/echo "Backup file my-system.backup.`date \'+20%y_%m_%d\'`.tar.gz successfully copied to my-backup-system" >> /home/user1/status/dns-status-my-system');
}
