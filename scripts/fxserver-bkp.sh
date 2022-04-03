#!/bin/bash

# Requirements:
# wget -O drive https://drive.google.com/uc?id=0B3X9GlR6EmbnMHBMVWtKaEZXdDg 
# mv drive /usr/sbin/drive 
# chmod 755 /usr/sbin/drive

# ask the user for required stuff
echo $'This script will backup your fx server to Google Drive.\n'

read -p "Enter the database username: " dbuser

read -s  -p "Enter the database password for $dbuser: " dbpass; echo $'\n'

read -p "Enter the database name: " dbname

read -p "Enter the path where the server.cfg is located: " cfg

read -p "Enter the root path: " root

read -p "Enter the path to store your backup: " path

read -p "Do you want to keep the backup locally (y/n): " choice

time=$(date '+%d-%m-%Y:%I-%M-%S')


# export database
echo "Exporting database..."
mysqldump -u$dbuser -p$dbpass $dbname| gzip > $cfg/rkr-db-$time.sql.gz
echo "Database exported."
sleep 3

# compress the directory
echo $'This may take a while, depending on the size of your server.\nCompressing directory...'
tar -zcf "$path/fx-$time.tar.gz" --exclude="node_modules" --exclude="$cfg/cache" --exclude="$cfg/db" "$root"
echo "Directory compressed."
sleep 3

if [ "$choice" == "y" ]; then
    # upload to google drive
    echo "Uploading to Google Drive..."
    drive upload -p DRIVE_PATH_ID -f "fx-$time.tar.gz"
    echo "Uploaded to Google Drive."
    sleep 3
    
    echo "Backup complete."
else if [ "$choice" == "n" ]; then

    # upload to google drive
    echo "Uploading to Google Drive..."
    drive upload -p DRIVE_PATH_ID -f "$path/fx-$time.tar.gz"
    echo "Uploaded to Google Drive."
    sleep 3

    # remove the database and compressed file
    echo "Clearing files..."
    sudo rm $cfg/$dbname-db.$time.sql.gz
    sudo rm "$path/fx-$time.tar.gz"
    echo "Cleared files."
    sleep 3
else
    echo "Invalid choice."
fi