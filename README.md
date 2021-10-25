# Piwigo-Docker

This is an image for piwigo, linked with a mysql database.
Data must be stored on a volume.

## Features
- Easy deployment of Piwigo with a docker-compose.

## Deployment

Edit this `docker-compose.yml` and launch with the command `$ docker-compose up -d `

```
mysqlpiwigo:
   image: mariadb:latest
   volumes:
      - /home/piwigo/mysql/:/var/lib/mysql
   environment:
      - MYSQL_ROOT_PASSWORD=MYROOTPASSWORD
      - MYSQL_DATABASE=piwigo
      - MYSQL_USER=piwigo
      - MYSQL_PASSWORD=MYUSERPASSWORD
piwigo:
   image: mathieuruellan/piwigo
   links:
      - mysqlpiwigo:mysql
   volumes:
      - /home/piwigo/data/galleries:/var/www/galleries
      - /home/piwigo/data/local:/var/www/local
      - /home/piwigo/data/plugins:/var/www/plugins
      - /home/piwigo/data/themes:/var/www/themes
      - /home/piwigo/cache:/var/www/_data/i
      - /home/piwigo/upload:/var/www/upload
      - /var/log
      - /var/log/piwigo:/var/log/apache2
   ports:
      - "MYPORT:80"
   hostname: piwigo
   domainname: MYDOMAIN.COM

```

After db initialization (first launch), environment variables can me removed.

.
