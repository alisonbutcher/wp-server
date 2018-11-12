add_header X-XSS-Protection "1; mode=block";
add_header X-Frame-Options "DENY";
add_header X-Content-Type-Options nosniff;

server {
        listen 80;
        listen [::]:80;
        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name alisonbutcher.com www.alisonbutcher.com;

        location / {
                try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
        client_max_body_size 50m;
}
