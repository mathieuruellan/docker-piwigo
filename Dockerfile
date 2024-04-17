FROM php:8.2-fpm-alpine

LABEL MAINTAINER="Mathieu Ruellan <mathieu.ruellan@gmail.com>"
ARG PIWIGO_VERSION="14.4.0"
ENV BASH_MODE="set -e"

RUN <<EOF
${BASH_MODE}
apk update
apk upgrade

apk add     wget \
            bash \
            curl \
            nginx \
            libpng \
            zlib \
            libcurl  \
            libxml2 \
            oniguruma \
            mediainfo \
            ffmpeg\
            imagemagick \
            wget \
            unzip \
            exiftool \
            libldap \
            php82-pecl-imagick \

EOF

RUN <<EOF
${BASH_MODE}

apk add     libpng-dev \
            curl-dev \
            zlib-dev \
            libxml2-dev \
            oniguruma-dev \
            imagemagick-dev \
            openldap-dev \

EOF

RUN <<EOF
${BASH_MODE}     
docker-php-ext-install ldap
docker-php-ext-install mbstring
docker-php-ext-install mysqli pdo pdo_mysql
docker-php-ext-install gd
docker-php-ext-install exif
docker-php-ext-install curl
docker-php-ext-install xml
EOF

RUN <<EOF
${BASH_MODE}

apk del     libpng-dev \
            curl-dev \
            zlib-dev \
            libxml2-dev \
            oniguruma-dev \
            imagemagick-dev \
            openldap-dev \

EOF

RUN <<EOF
${BASH_MODE}
rm /var/www/* -rf
wget -q -O /tmp/piwigo.zip http://piwigo.org/download/dlcounter.php?code=$PIWIGO_VERSION
unzip /tmp/piwigo.zip -d /tmp/
mv /tmp/piwigo/* /var/www/
rm -r /tmp/piwigo.zip
mkdir /template
mv /var/www/galleries /template/
mv /var/www/themes /template/
mv /var/www/plugins /template/
mv /var/www/local /template/
mkdir -p /var/www/_data/i /config
chown -R www-data:www-data /var/www
EOF

VOLUME ["/var/www/galleries", "/var/www/themes", "/var/www/plugins", "/var/www/local", "/var/www/_data/i", "/config"]

COPY <<EOF /usr/local/etc/php/conf.d/piwigo.ini
[PHP]
max_execution_time = 300
memory_limit = 512M
max_input_time = 180
post_max_size = 100M
upload_max_filesize = 100M
EOF


COPY <<EOF /etc/nginx/nginx.conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF

COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    index index.php index.html;

    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;

    root /var/www;

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass localhost:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
}
EOF

COPY <<EOF /entrypoint.sh
#!/bin/bash
${BASH_MODE}
for d in $(ls /template); do
  [ -f "/var/www/${d}" ] || cp -R /template/${d}/* /var/www/${d}/
done

chown -R www-data:www-data /var/www

if [ ! -z "${PIWIGO_MYSQL_ENGINE}" ]; then
	grep -Rn MyISAM /var/www/install | cut -d: -f1 | sort -u | while read file; do
		sed -i 's/MyISAM/InnoDB/' "${file}";
	done;
fi;

php-fpm -D
nginx -g \"daemon off;\"
EOF

RUN chmod u+x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
EXPOSE 80
