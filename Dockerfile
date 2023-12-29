FROM php:8.2-fpm-alpine

LABEL MAINTAINER="Mathieu Ruellan <mathieu.ruellan@gmail.com>"

#ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ARG PIWIGO_VERSION="14.1.0"

RUN <<EOF
set -e
apk update
apk upgrade

apk add     wget \
            bash \
            curl \
            nginx \
            php82-fpm \
            libpng libpng-dev \
            zlib zlib-dev \
            libcurl curl-dev \
            libxml2 libxml2-dev \
            oniguruma oniguruma-dev \


#mysql
docker-php-ext-install mysqli pdo pdo_mysql
docker-php-ext-install gd
docker-php-ext-install exif
docker-php-ext-install curl
docker-php-ext-install xml
docker-php-ext-install mbstring

#image magick
apk add --no-cache --virtual .build-deps \$PHPIZE_DEPS imagemagick-dev
pecl install imagick
docker-php-ext-enable imagick
apk del .build-deps

apk add \
            mediainfo \
            ffmpeg\
            imagemagick \
            wget \
            unzip \
            exiftool 


#RUN <<EOF 
#set -e
#apt update -yy
#apt install -yy --no-install-recommends  --no-install-suggests \
#            wget curl \
#            nginx \
 #           php8.2-fpm \
 #           php8.2-gd \
 #           php8.2-curl \
 #           php8.2-mysql \
 ####           php8.2-mbstring \
 #           php8.2-xml \
 #           php8.2-imagick \
 #           dcraw \
 #           mediainfo \
 #           ffmpeg\
 #           imagemagick \
 #           wget \
 #           unzip \
 #           exiftool 
#rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#EOF

RUN <<EOF
set -exv
wget -q -O piwigo.zip http://piwigo.org/download/dlcounter.php?code=$PIWIGO_VERSION
unzip piwigo.zip
rm /var/www/* -rf
mv piwigo/* /var/www/
rm -r piwigo*
mkdir /template
mv /var/www/galleries /template/
mv /var/www/themes /template/
mv /var/www/plugins /template/
mv /var/www/local /template/
mkdir -p /var/www/_data/i /config
chown -R www-data:www-data /var/www
sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/8.2/fpm/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/8.2/fpm/php.ini
sed -i "s/max_input_time = 60/max_input_time = 180/" /etc/php/8.2/fpm/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php/8.2/fpm/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/8.2/fpm/php.ini
EOF

VOLUME ["/var/www/galleries", "/var/www/themes", "/var/www/plugins", "/var/www/local", "/var/www/_data/i", "/config"]



COPY <<EOF /etc/nginx/sites-enabled/default
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
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
}
EOF


ENV BASH_MODE="set -e"
COPY <<EOF /entrypoint.sh
#!/bin/bash
\${BASH_MODE}
for d in $(ls /template); do
  [ -f "/var/www/${d}" ] || cp -R /template/${d}/* /var/www/${d}/
done

chown -R www-data:www-data /var/www

if [ ! -z "${PIWIGO_MYSQL_ENGINE}" ]; then
	grep -Rn MyISAM /var/www/install | cut -d: -f1 | sort -u | while read file; do
		sed -i 's/MyISAM/InnoDB/' "${file}";
	done;
fi;

php-fpm8.2 -D
nginx -g \"daemon off;\"
EOF

RUN chmod u+x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
EXPOSE 80
