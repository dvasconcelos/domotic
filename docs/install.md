# Installation

## LXD

- Create the container

```
sudo lxc launch ubuntu:18.04 domotic
```

- Update container

```
sudo lxc exec domotic -- apt-get update
sudo lxc exec domotic -- apt-get updates
```

- Get container IP and add SSH key

```
export EXTERNAL_IP=$(sudo lxc info domotic | grep eth0 | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
sudo grep -q 'domotic.lxc' /etc/hosts || echo $EXTERNAL_IP' domotic.lxc' | sudo tee -a /etc/hosts
export INTERNAL_IP=$(sudo lxc info domotic | grep lo | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
sudo lxc exec domotic -- grep -q 'domotic.lxc' /etc/hosts || echo $INTERNAL_IP' domotic.lxc # Added by LXC Installation' | sudo lxc exec domotic -- tee -a /etc/hosts
export SSH_KEY=$(cat ~/.ssh/id_rsa.pub)=
echo $SSH_KEY | sudo lxc exec domotic -- tee -a /root/.ssh/authorized_keys
echo $SSH_KEY | sudo lxc exec domotic -- tee -a /home/ubuntu/.ssh/authorized_keys
```

- Mount local folder

```
sudo lxc config set domotic raw.idmap 'both 1000 1000'
sudo lxc restart domotic
ssh root@domotic.lxc
cd /var/www/
mkdir domotic
exit
cd <project_dir>
sudo lxc config device add domotic homedir disk source=$(pwd) path=/var/www/domotic
```

## Web server

- Install apache and php

```
ssh root@domotic.lxc
apt install apache2 -y
apt install libapache2-mod-fcgid -y
apt install php7.2 -y
apt install php7.2-fpm php7.2-xml php7.2-curl php7.2-mbstring php7.2-zip -y
apt install mariadb-client mariadb-server -y
```

- Install composer

```
wget https://getcomposer.org/download/1.8.3/composer.phar
mv composer.phar /usr/bin/composer
chmod a+x /usr/bin/composer
```

- Configure PHP FPM pool in the container, add the following line to /etc/php/7.2/fpm/pool.d/www.conf:

```
listen = 127.0.0.1:9000
```

- Restart PHP FPM

```
systemctl restart php7.2-fpm
```

- Configure Apache in the container, adding the following file /etc/apache2/sites-available/domotic.lxc.conf

```
<VirtualHost *:80>
    ServerName domotic.lxc

    # Uncomment the following line to force Apache to pass the Authorization
    # header to PHP: required for "basic_auth" under PHP-FPM and FastCGI
    #
    # SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1

    # For Apache 2.4.9 or higher
    # Using SetHandler avoids issues with using ProxyPassMatch in combination
    # with mod_rewrite or mod_autoindex
    <FilesMatch \.php$>
        SetHandler proxy:fcgi://127.0.0.1:9000
        # for Unix sockets, Apache 2.4.10 or higher
        # SetHandler proxy:unix:/path/to/fpm.sock|fcgi://dummy
    </FilesMatch>

    # If you use Apache version below 2.4.9 you must consider update or use this instead
    # ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/var/www/project/public/$1

    # If you run your Symfony application on a subpath of your document root, the
    # regular expression must be changed accordingly:
    # ProxyPassMatch ^/path-to-app/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/var/www/project/public/$1

    DocumentRoot /var/www/domotic/public
    <Directory /var/www/domotic/public>
        AllowOverride None
        Order Allow,Deny
        Allow from All

        FallbackResource /index.php
    </Directory>

    # uncomment the following lines if you install assets as symlinks
    # or run into problems when compiling LESS/Sass/CoffeeScript assets
    <Directory /var/www/domotic>
       Options FollowSymlinks
    </Directory>

    # optionally disable the fallback resource for the asset directories
    # which will allow Apache to return a 404 error when files are
    # not found instead of passing the request to Symfony
    <Directory /var/www/domotic/public/bundles>
        FallbackResource disabled
    </Directory>

    ErrorLog /var/log/apache2/project_error.log
    CustomLog /var/log/apache2/project_access.log combined
</VirtualHost>
```

- Enable Apache modules

```
a2enmod proxy
a2enmod proxy_fcgi
a2enmod rewrite
```

- Enable vhost

```
 a2dissite 000-default.conf
 a2ensite domotic.lxc.conf
 systemctl restart apache2
```
