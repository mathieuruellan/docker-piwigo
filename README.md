# This project is no longer maintained. 

I've stopped using piwigo due to bugs never fixed. 
You can export and rebuild your virtual albums structure into file directory with this tools: https://github.com/mathieuruellan/piwigo-exporter


# Piwigo-Docker

This is an image for piwigo, linked with a mysql database.
Data must be stored on a volume.

## Features
- Easy deployment of Piwigo with a docker-compose.

## Deployment

Edit this `docker-compose.yml` and launch with the command 

```
mkdir -p ./piwigo/data/local/config
chmod -R 0777 ./piwigo
 docker-compose up -d 
```

```
services:
  mariadb:
    image: mariadb:latest
    volumes:
        - ./piwigo/mysql/:/var/lib/mysql
    environment:
        - MARIADB_ROOT_PASSWORD=piwigo
        - MARIADB_DATABASE=piwigo
        - MARIADB_USER=piwigo
        - MARIADB_PASSWORD=piwigo
  piwigo:
    image: mathieuruellan/piwigo
    environment:
        - BASH_MODE=set -e
    depends_on:
        - mariadb
    volumes:
        - ./piwigo/data/galleries:/var/www/galleries
        - ./piwigo/data/local:/var/www/local
        - ./piwigo/data/plugins:/var/www/plugins
        - ./piwigo/data/themes:/var/www/themes
        - ./piwigo/cache:/var/www/_data/i
        - ./piwigo/upload:/var/www/upload
        - ./var/log:/var/log
        - ./var/log/piwigo:/var/log/apache2
    ports:
        - "9999:80"
    hostname: localhost
    domainname: mydomain

```

After db initialization (first launch), environment variables can me removed.


EDIT: installation with version 13.x from scratch  seems to be broken.
Install with mathieuruellan/piwigo:12.3.0 first and upgrade
