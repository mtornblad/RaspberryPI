Back up your Pi to your Google drive

Being able to back up data to the cloud is very useful. It means that even if your Raspberry Pi dies or your SD card gets corrupted, your data is still safe. It also means that you can access your data from any where in the world.

If you have a Google drive account, you can use the grive program to sync a folder on your Pi with your Google drive.

Install grive

Start by making sure that your Pi's software is up to date, install some additional packages, and get the code using git:

$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install git cmake build-essential libgcrypt11-dev libjson0-dev libcurl4-openssl-dev libexpat1-dev libboost-filesystem-dev libboost-program-options-dev binutils-dev libboost-test-dev libqt4-dev libyajl-dev

$ git clone git://github.com/Grive/grive.git
Modify /home/pi/grive/libgrive/src/drive/State.cc to resolve some compiler problems. Lines that use the Add() method need to contain a cast to the correct size of integer. The expression "(boost::uint64_t)" must be added to lines 251, 252 and 256. The updated code should look like this:


void State::Write( const fs::path& filename ) const
{
    Json last_sync ;
    last_sync.Add( "sec", Json((boost::uint64_t)m_last_sync.Sec() ) );
    last_sync.Add( "nsec", Json((boost::uint64_t)m_last_sync.NanoSec() ) );

    Json result ;
    result.Add( "last_sync", last_sync ) ;
    result.Add( "change_stamp", Json((boost::uint64_t)m_cstamp) ) ;
	
    std::ofstream fs( filename.string().c_str() ) ;
    fs << result ;
}

Now you need to configure the make files by running cmake (note the '.' after the cmake command) and compile the source code by running make:


$ cd ./grive
$ cmake .
$ make

You need to create a directory where you can store files that you want to be syncronized with your Google drive, and copy the grive executable to that directory.


$ mkdir ~/google_drive
$ cp ./grive/grive ~/google_drive

The first time you execute grive, you need to use the -a option in order to authenticate with Google. You must be logged into your Google account from your Pi for this to work. If you're logged into your Google account on a PC or laptop, log out, and then log in again using a browser on your Pi. Once you've done this, change to your Google drive directory and run grive.


$ cd ../google_drive/
$ ./grive -a

A link will be printed in the terminal window. Copy the link and paste it in a browser. A page on google.com will appear with a long code that you need to enter in the terminal window. Pasting the code didn't work for me, so you may have to type it in. The authentication process will then take place, and your Pi will sync for the first time. Before you do this, check to see how much space you've used up on your Google drive, and check to see if there's enough space on your Pi's SD card.

Running a backup to the cloud

If you've got this far, you should now be able to sync files and folders in /home/pi/google_drive with your Google drive. The next step is to backup the data on your Pi and upload it to your Google drive.

The following bash script creates a tar archive containing my home directory. I've made sure not to include the Google drive directory in this archive, otherwise previous archives would be included in the backup. The second line compresses the archive into a .tar.gz file. The file is moved to the google drive directory before running grive to upload the new archive to your Google drive on the internet. I've used the date command to embed the current date in the file name.


#!/bin/bash

tar -crvf backup_$(date +%y.%m.%d).tar /home/pi --exclude="/home/pi/google_drive"
gzip backup_$(date +%y.%m.%d).tar
mv backup_$(date +%y.%m.%d).tar.gz ./google_drive
cd ./google_drive 
./grive
cd ..


Save this code as grive_backup.sh, and make it executable using the chmod +x command.

When you run the script, it may appear to hang while gzip is running. This may take a few minutes depending on how much data there is in your home directory.

Running a backup script as cron job

This script can eaily be automated by creating an entry in the crontab file. Linux uses the crontab file to schedule tasks. Entries are made in the format

minute hour day_of_month month day_of_week username command
Use this command to open crontab:

$ sudo leafpad /etc/crontab
...and then add this line:

00 03 * * * pi /home/pi/grive_backup.sh
This specifies that you want to run grive_backup.sh at 3.00am every day, and it should be run as user pi. Linux should automatically detect that your crontab file has been modified, so there's no need to reboot.

Your SD card will fill up after a few days or weeks, so it's best to remove old backups. You can do this by adding the following line to the script above:

rm backup_$(date --date="7 days ago" +%y.%m.%d).tar.gz
This time the date command is being used to create a date from 7 days ago, so a back up file from 7 days ago will be deleted.


