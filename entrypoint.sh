#!/bin/bash

for d in $(ls /template); do
  [ "$(ls -A /var/www/${d})" ] || cp -R /template/${d}/* /var/www/${d}/

done

sed -i "s/\/var\/www\/html/\/var\/www/g"  /etc/apache2/sites-enabled/000-default.conf

chown -R www-data:www-data /var/www

source /etc/apache2/envvars
apache2ctl -D FOREGROUND
