FROM debian:wheezy-slim

MAINTAINER Mathieu Ruellan <mathieu.ruellan@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

ARG PIWIGO_VERSION="2.9.2"

RUN apt-get update \
     && apt-get dist-upgrade -yy \
     && apt-get install apache2 libapache2-mod-php5 -yy \
     && apt-get install -yy php5-mysql imagemagick wget unzip \
     && apt-get install -yy php5-gd php5-ffmpeg dcraw mediainfo ffmpeg \
     && apt-get install -yy php5-gd php5-curl php5-ffmpeg dcraw mediainfo ffmpeg \
     && wget http://mediaarea.net/download/binary/mediainfo/0.7.74/mediainfo_0.7.74-1_amd64.Debian_7.0.deb \
     && wget http://mediaarea.net/download/binary/libmediainfo0/0.7.74/libmediainfo0_0.7.74-1_amd64.Debian_7.0.deb \
     && wget http://mediaarea.net/download/binary/libzen0/0.4.31/libzen0_0.4.31-1_amd64.Debian_7.0.deb \
     && dpkg -i libzen0_0.4.31-1_amd64.Debian_7.0.deb libmediainfo0_0.7.74-1_amd64.Debian_7.0.deb mediainfo_0.7.74-1_amd64.Debian_7.0.deb \
     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* *.deb

RUN wget -q -O piwigo.zip http://piwigo.org/download/dlcounter.php?code=$PIWIGO_VERSION && \
    unzip piwigo.zip && \
    rm /var/www/* -rf && \
    mv piwigo/* /var/www && \
    rm -r piwigo*

ADD php.ini /etc/php5/apache2/php.ini

RUN mkdir /template
RUN mv /var/www/galleries /template/
RUN mv /var/www/themes /template/
RUN mv /var/www/plugins /template/
RUN mv /var/www/local /template/

RUN mkdir -p /var/www/_data/i
RUN chown -R www-data:www-data /var/www

VOLUME ["/var/www/galleries", "/var/www/themes", "/var/www/plugins", "/var/www/local", "/var/www/_data/i"]

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh
EXPOSE 80

