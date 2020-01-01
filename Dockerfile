FROM debian:buster-slim

MAINTAINER Mathieu Ruellan <mathieu.ruellan@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

ARG PIWIGO_VERSION="2.10.1"

RUN apt update -y \
     && apt install -yy \
            apache2 \
            libapache2-mod-php \
            php-gd \
            php-curl \
            php-mysql \
            php-mbstring \
            php-xml \
            php-imagick \
            dcraw \
            mediainfo \
            ffmpeg\
            imagemagick \
            wget \
            unzip \
            exiftool \
     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -q -O piwigo.zip http://piwigo.org/download/dlcounter.php?code=$PIWIGO_VERSION && \
    unzip piwigo.zip && \
    rm /var/www/* -rf && \
    mv piwigo/* /var/www/ && \
    rm -r piwigo* && \
    mkdir /template && \
    mv /var/www/galleries /template/ && \
    mv /var/www/themes /template/ && \
    mv /var/www/plugins /template/ && \
    mv /var/www/local /template/ && \
    mkdir -p /var/www/_data/i /config && \
    chown -R www-data:www-data /var/www &&\
    sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.3/apache2/php.ini &&\
    sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/7.3/apache2/php.ini &&\
    sed -i "s/max_input_time = 60/max_input_time = 180/" /etc/php/7.3/apache2/php.ini &&\
    sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php/7.3/apache2/php.ini &&\
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/7.3/apache2/php.ini

VOLUME ["/var/www/galleries", "/var/www/themes", "/var/www/plugins", "/var/www/local", "/var/www/_data/i", "/config"]

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
EXPOSE 80
