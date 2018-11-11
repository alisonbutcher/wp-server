#!/bin/bash

#PARAMETERS
DOMAIN="alisonbutcher.com"
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
sudo adduser $USER --gecos "Alison Butcher,none,none,none" --disabled-password
echo "myuser:password" | sudo chpasswd 

#Set groups
echo "Adding user to sudo"
usermod -aG sudo $USER

#copy ssh keys
rsync --archive --chown=$USER:$USER ~/.ssh /home/$USER

#configure firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable

#update packages
apt update
apt upgrade -y

#install servers
apt install nginx mysql-server-5.7 php-fpm php-mysql -y

#new server block nginx
curl --http1.1 http://example.com/somefile --output etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

#add lets-encrypt
apt add-apt-repository ppa:certbot/certbot -y
apt install python-certbot-nginx
sudo apt update

#secure mysql
mysql_secure_installation

#get ssl
certbot --nginx --email --agree-tos $SSL_EMAIL -d $DOMAIN -d www.$DOMAIN



