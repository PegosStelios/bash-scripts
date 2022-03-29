#!/bin/bash

#check that the user is root, if yes install mariadb, else throw error
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#ask the user requires stuff
IFS= read -s  -p "Enter the root password for root user: " rootpass

read -p "Enter the database user: " dbuser

IFS= read -s  -p "Enter the database password: " rootpass

read -p "Enter the database name: " dbname

echo "Installing packages"

#install mariadb
apt-get update
apt-get install -y mariadb-server

echo "Performing basic configuration"

# Change root password to the one the user entered
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$rootpass') WHERE User = 'root'"

# Because sometimes a user with the hostname gets made, drop it.
sudo mysql -e "DROP USER IF EXISTS ''@'$(hostname)'"

# Drop test database
sudo mysql -e "DROP DATABASE IF EXISTS test"

# Remove anonymous users
sudo mysql -e "DROP USER IF EXISTS ''@'localhost'"

echo "Creating database"

# create a database and a user
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $dbname"
mysql -u root -e "CREATE USER IF NOT EXISTS '$dbuser'@'%' IDENTIFIED BY '$dbpass'"
mysql -u root -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'%'"
mysql -u root -e "FLUSH PRIVILEGES"

# allow remote access to the database
sed -i "s/^#bind-address            = *.*.*.*/bind-address            = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

#restart the mysql service
systemctl restart mysql