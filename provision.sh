#!/usr/bin/env bash

# Update All Packages

apt-get update
apt-get upgrade -y

# Install Some PPAs

apt-get install -y software-properties-common

apt-add-repository ppa:nginx/stable -y
apt-add-repository ppa:rwky/redis -y
apt-add-repository ppa:chris-lea/node.js -y

# Update Package Lists

apt-get update

# Add My Public SSH Key

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAoCkaXT71oVSZb5KA+5ywfjdtUPXxb5XznNu5cFwrYYhEYBZkaoYKTg7dL40tfOo9pJnvMpQv8i+IcYP9bUZ3u5VD2IuINlvlcCElUoB/kwQr7Vr5IYDJZa0Fy6bNpv7jTDRfQGZzeWMeDtsF+1MyLqyNqmfi34gEnQadaKwJzLqVMG79uYHwrudQKktdJEQx67wNZ3rGXZhx4KFJw9KqqQZGZHCM9JgDqKHfCenn3TaFkc7zP7PmaqiiXfIQbnGczygYnIuf9/1tYSqPdNvZCRBhFrSgnNPTfHABVSzUrtbleHjZaDoCwpebInkcS3ysaa18zzZvkraKqbSbbZNh7Q== rsa-key-20131228" | tee -a /home/vagrant/.ssh/authorized_keys

# Install Some Basic Packages

apt-get install -y build-essential curl gcc git libmcrypt4 libpcre3-dev \
make python-pip supervisor unattended-upgrades whois

# Httpie Is A Simple Python Tool For Doing HTTP Stuff

pip install httpie

# Set My Timezone

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

# Install PHP Stuffs

apt-get install -y php5-cli php5-dev php-pear \
php5-mysql php5-pgsql php5-sqlite \
php5-apcu php5-json php5-curl php5-dev php5-gd php5-gmp php5-mcrypt php5-xdebug php5-memcached

# Make MCrypt Available

ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt

# Install Mailparse PECL Extension

pecl install mailparse
echo "extension=mailparse.so" > /etc/php5/mods-available/mailparse.ini
ln -s /etc/php5/mods-available/mailparse.ini /etc/php5/cli/conf.d/20-mailparse.ini

# Install Composer

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Set Some PHP CLI Settings

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/cli/php.ini

# Install Nginx & PHP-FPM

apt-get install -y nginx php5-fpm

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
service nginx restart

# Setup Some PHP-FPM Options

ln -s /etc/php5/mods-available/mailparse.ini /etc/php5/fpm/conf.d/20-mailparse.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/fpm/php.ini

# Set The Nginx & PHP-FPM User

sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf

service nginx restart
service php5-fpm restart

# Add Vagrant User To WWW-Data

usermod -a -G www-data vagrant
id vagrant
groups vagrant

# Install Node

apt-get install -y nodejs
npm install -g grunt-cli
npm install -g gulp

# Install MySQL

debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
apt-get install -y mysql-server

# Configure MySQL Remote Access

sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 10.0.2.15/' /etc/mysql/my.cnf
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'10.0.2.2' IDENTIFIED BY 'secret';"
service mysql restart

mysql --user="root" --password="secret" -e "CREATE USER 'forge'@'{{ $server->ip_address }}' IDENTIFIED BY 'secret';"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'forge'@'{{ $server->ip_address }}' IDENTIFIED BY 'secret';"
mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"

# Install Postgres

apt-get install -y postgresql

# Configure Postgres Remote Access

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.1/main/postgresql.conf
echo "host    all             all             10.0.2.2/32               md5" | tee -a /etc/postgresql/9.1/main/pg_hba.conf
sudo -u postgres psql -c "CREATE ROLE vagrant LOGIN UNENCRYPTED PASSWORD 'secret' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres /usr/bin/createdb --echo --owner=vagrant vagrant
service postgresql restart

# Install A Few Other Things

apt-get install -y redis-server memcached beanstalkd
