#!/bin/bash

version="1.1.0"

#PARAMETERS
DOMAIN="dev.alisonbutcher.com"
USER="alison"
SSL_EMAIL="alisonkbutcher@gmail.com"

# Are we running with root access
[ $# -eq 0 ] && { echo "Usage: $0 <version>"; exit; }
if [[ $EUID -ne 0 ]] ; then
  echo "Error: Must be run with root access"
  exit 1
fi

# Add non root user
echo "Adding general user"
adduser $USER --gecos "none,none,none,none" --disabled-password

#Generate / Assign Password for user
PWD=$(openssl rand -base64 8)
echo $USER:$PWD | chpasswd 

#Set groups
echo "Adding user to sudo"
usermod -aG sudo $USER

#copy ssh keys
rsync --archive --chown=$USER:$USER ~/.ssh /home/$USER

#configure firewall
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw enable

#update packages
apt update
DEBIAN_FRONTEND=noninteractive apt -y upgrade

#install servers
apt install nginx mysql-server-5.7 php-fpm php-mysql -y
apt install software-properties-common -y 

#new server block nginx
cp website.com /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

#add lets-encrypt
add-apt-repository ppa:certbot/certbot -y
apt install python-certbot-nginx -y 
apt update

#get ssl
certbot --agree-tos --nginx --email $SSL_EMAIL -d $DOMAIN

# remove default nginx site
rm /etc/nginx/sites-available/default

# copy php test file to webroot
cp index.php /var/www/html

mysql_secure_installation


echo "Created new user $USER with password $PWD. Please write it down now."



