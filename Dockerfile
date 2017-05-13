FROM debian:wheezy

MAINTAINER Mathieu Ruellan <mathieu.ruellan@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

RUN apt-get update \
     && apt-get upgrade -yy \
     && apt-get install apache2 libapache2-mod-php5 -yy \
     && apt-get install -yy php5-mysql imagemagick wget unzip \
     && apt-get install -yy php5-gd php5-ffmpeg dcraw mediainfo ffmpeg \
     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -q -O piwigo.zip http://piwigo.org/download/dlcounter.php?code=2.9.0 && \
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

