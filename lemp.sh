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
sudo adduser $USER --gecos "Alison Butcher,none,none,none" --disabled-password
echo "myuser:password" | sudo chpasswd 

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

#new server block nginx
# cp website-ssl.com.conf /etc/nginx/sites-available/$DOMAIN-ssl 
cp website.com /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
# ln -s /etc/nginx/sites-available/$DOMAIN-ssl /etc/nginx/sites-enabled/

#add lets-encrypt
apt add-apt-repository ppa:certbot/certbot -y
apt install python-certbot-nginx
sudo apt update

#get ssl
certbot --nginx --email $SSL_EMAIL --agree-tos -d $DOMAIN
# use below instead of above if you have www version of domain as well
# certbot --nginx --email $SSL_EMAIL --agree-tos -d $DOMAIN -d www.$DOMAIN


echo "Once you have done the above you should run mysql.sh to complete the installation"




