FROM debian:bookworm-slim

LABEL MAINTAINER="Mathieu Ruellan <mathieu.ruellan@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ARG PIWIGO_VERSION="13.8.0"

RUN <<EOF
set -e
apt update -yyq
apt install -yyq ca-certificates apt-transport-https software-properties-common wget curl lsb-release sudo
curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF

RUN <<EOF 
set -e
apt update -yy
apt install -yy \
            apache2 \
            libapache2-mod-php8.1 \
            php8.1-gd \
            php8.1-curl \
            php8.1-mysql \
            php8.1-mbstring \
            php8.1-xml \
            php8.1-imagick \
            dcraw \
            mediainfo \
            ffmpeg\
            imagemagick \
            wget \
            unzip \
            exiftool 
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF

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
sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/8.1/apache2/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/8.1/apache2/php.ini
sed -i "s/max_input_time = 60/max_input_time = 180/" /etc/php/8.1/apache2/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php/8.1/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/8.1/apache2/php.ini
EOF

VOLUME ["/var/www/galleries", "/var/www/themes", "/var/www/plugins", "/var/www/local", "/var/www/_data/i", "/config"]


ENV BASH_MODE="set -e"
COPY <<EOF /entrypoint.sh
#!/bin/bash
\${BASH_MODE}
for d in $(ls /template); do
  [ "$(ls -A /var/www/${d})" ] || cp -R /template/${d}/* /var/www/${d}/
done

sed -i 's/\\/var\\/www\\/html/\\/var\\/www/g'  /etc/apache2/sites-enabled/000-default.conf
sed -i '/^\s*DocumentRoot.*/a \\tSetEnv HTTPS on' /etc/apache2/sites-enabled/000-default.conf

chown -R www-data:www-data /var/www

if [ ! -z "${PIWIGO_MYSQL_ENGINE}" ]; then
	grep -Rn MyISAM /var/www/install | cut -d: -f1 | sort -u | while read file; do
		sed -i 's/MyISAM/InnoDB/' "${file}";
	done;
fi;

source /etc/apache2/envvars
apache2ctl -D FOREGROUND
EOF

RUN chmod u+x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
EXPOSE 80
