# ARCH

## MySQL (MariaDB)

https://wiki.archlinux.org/index.php/MariaDB#Installation

`pacman -S mariadb`

`mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql`

`systemctl enable --now mysql`

`mysql_secure_installation`


## PHP

`pacman -S php imagemagick php-imagick`

> /etc/php/php.ini

`date.timezone = Europe/Amsterdam`

`zend_extension=opcache`

```
extension=pdo_sqlite
extension=sqlite3
extension=pdo_mysql
extension=mysqli
```

### php-imagick

`pacman -S imagemagick php-imagick`

> //etc/php/conf.d/imagick.ini

`extension=imagick`


### opcache

> /etc/php/php.ini

`zend_extension=opcache`

```
opcache.enable=1
opcache.enable_cli=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
```


### gd en intl

`pacman -S php-gd php-intl`

> /etc/php/php.ini

```
extension=gd 
extension=intl
extension=zip
extension=curl
```

### 'recommended'

`pacman -S php-sqlite php-imap php-fpm ffmpeg curl wget`


## Nextcloud

__1. install

`pacman -S nextcloud`

> Config: /etc/webapps/nextcloud/config/config.php

__2. create database

```
mysql -u root -p
mysql> CREATE DATABASE nextcloud DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci';
mysql> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;
mysql> \q
```

__3. setup

`occ maintenance:install --database pgsql --database-name nextcloud --database-host localhost --database-user nextcloud --database-pass=<password> --data-dir /var/lib/nextcloud/data/`

_(or use the webinterface)

__4. add admin user

`occ user:add --display-name="Richard vdB" --group="users" --group="db-admins" --group="db-admins" richardpp`



### APCu caching

__1. APCu can be installed with the php-apcu package. Recommended configuration:

> /etc/php/conf.d/apcu.ini

```
extension=apcu.so
apc.enabled=1
apc.shm_size=32M
apc.ttl=7200
apc.enable_cli=1

```

__2. Nextcloud config

> config.php

`'memcache.local' => '\OC\Memcache\APCu',`


## php-fpm

> /etc/php/php-fpm.d/nextcloud.conf

```
[nextcloud]
user = nextcloud
group = nextcloud
listen = /run/nextcloud/nextcloud.sock
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp

; should be accessible by your web server
listen.owner = http
listen.group = http

pm = dynamic
pm.max_children = 15
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```


> /etc/systemd/system/php-fpm.service.d/override.conf

`systemctl edit php-fpm.service`

```
[Service]
# Your data directory
ReadWritePaths=/var/lib/nextcloud/data

# Optional: add if you've set the default apps directory to be writable in config.php
ReadWritePaths=/usr/share/webapps/nextcloud/apps

# Optional: unnecessary if you've set 'config_is_read_only' => true in your config.php
ReadWritePaths=/usr/share/webapps/nextcloud/config
ReadWritePaths=/etc/webapps/nextcloud/config

# Optional: add if you want to use Nextcloud's internal update process
# ReadWritePaths=/usr/share/webapps/nextcloud
```

`systemctl enable --now php-fpm`


## nginx

`pacman -S nginx`

> /etc/nginx/nginx.conf

```
keepalive_timeout 65;
types_hash_max_size 4096;
```


...


## hosts / hostname



## certbot

`pacman -S certbot certbot-nginx`

`certbot --nginx`

...werkt alleen als:
1. nginx -t ook succesvol is
2. de DNS records naar de juiste server staan.
3. de configuratiebestanden van nginx correct zijn ingesteld, anders moeten de aangemaakte sleutels handmatig worden toegevoegd in de serverblocks:

```
ssl_certificate /etc/letsencrypt/live/DOMAIN/fullchain.pem; # managed by Certbot
ssl_certificate_key /etc/letsencrypt/live/DOMAIN/privkey.pem; # managed by Certbot
include /etc/letsencrypt/options-ssl-nginx.conf;
```


Vergeet ook niet de cron-job te starten voor het automatisch verlengen van het certificaat: 


Check of de renewal werkt: `certbot renew --dry-run`

### autorenewal

__1. Create a systemd certbot.service:*

> /etc/systemd/system/certbot.service

```
[Unit]
Description=Let's Encrypt renewal

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --quiet --agree-tos --deploy-hook "systemctl reload nginx.service"
```


__2. Add a timer to check for certificate renewal twice a day and include a randomized delay so that everyone's requests for renewal will be spread over the day to lighten the Let's Encrypt server load [2]:

> /etc/systemd/system/certbot.timer

```
[Unit]
Description=Twice daily renewal of Let's Encrypt's certificates

[Timer]
OnCalendar=*-*-* 0:30:00
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

__3. Enable and start certbot.timer

`systemctl enable --now certbot.timer`
