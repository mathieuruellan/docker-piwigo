FROM debian:stretch-slim

MAINTAINER Mathieu Ruellan <mathieu.ruellan@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

ARG PIWIGO_VERSION="2.9.4"

RUN apt-get update \
     && apt-get install -yy \
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
            libav-tools \
            mediainfo \
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
    chown -R www-data:www-data /var/www

ADD php.ini /etc/php/7.0/apache2/php.ini
VOLUME ["/var/www/galleries", "/var/www/themes", "/var/www/plugins", "/var/www/local", "/var/www/_data/i", "/config"]

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
EXPOSE 80
