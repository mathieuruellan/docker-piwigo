#!/bin/bash

for d in $(ls /template); do
  [ "$(ls -A /var/www/${d})" ] || cp -R /template/${d}/* /var/www/${d}/

done

mkdir -pv /config/php/apache2.d
find /config/php/apache2.d -type f | while read file; do
	ln -svf "${file}" "/etc/php/7.0/apache2/conf.d/$(basename "${file}")";
done;

sed -i "s/\/var\/www\/html/\/var\/www/g"  /etc/apache2/sites-enabled/000-default.conf

chown -R www-data:www-data /var/www

source /etc/apache2/envvars
apache2ctl -D FOREGROUND

