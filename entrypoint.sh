#!/bin/bash

for d in $(ls /template); do
  [ "$(ls -A /var/www/${d})" ] || cp -R /template/${d}/* /var/www/${d}/

done

chown -R www-data:www-data /var/www

source /etc/apache2/envvars
apache2ctl -D FOREGROUND
 
