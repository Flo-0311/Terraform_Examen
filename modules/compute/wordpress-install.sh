#!/bin/bash
apt-get update
apt-get install -y apache2 mysql-client php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc

# Download WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
cp -R wordpress/* /var/www/html/
rm /var/www/html/index.html

# WordPress Configuration
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/${db_name}/" /var/www/html/wp-config.php
sed -i "s/username_here/${db_username}/" /var/www/html/wp-config.php
sed -i "s/password_here/${db_password}/" /var/www/html/wp-config.php
sed -i "s/localhost/${db_endpoint}/" /var/www/html/wp-config.php

# Set permissions
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Start Apache
systemctl enable apache2
systemctl start apache2
