#add lets-encrypt
apt add-apt-repository ppa:certbot/certbot -y
apt install python-certbot-nginx
sudo apt update

#get ssl
certbot --nginx --email $SSL_EMAIL --agree-tos -d $DOMAIN
# use below instead of above if you have www version of domain as well
# certbot --nginx --email $SSL_EMAIL --agree-tos -d $DOMAIN -d www.$DOMAIN