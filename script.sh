#!/bin/bash

echo "Installation paquets APT"
apt update
apt install -y mariadb-server mariadb-client
apt install -y php apache2 libapache2-mod-php php-mysql php-xml
apt install -y composer vim git snapd

echo "Config snapd + certbot"
snap install core
snap refresh core
snap install --classic certbot

CERTBOT=$(ls /usr/bin | grep certbot)
if [ -z "$CERTBOT" ]
then
  echo "On créé le lien /usr/bin/certbot"
  ln -s /snap/bin/certbot /usr/bin/certbot
fi

MD5_DEST=$(md5sum /etc/apache2/sites-available/000-default.conf | awk '{print $1}')
MD5_SRC=$(md5sum 000-default.conf | awk '{print $1}')

if [ "$MD5_DEST" != "$MD5_SRC" ]
then
	echo "On écrase la conf apache"
	cp 000-default.conf /etc/apache2/sites-available/000-default.conf
	service apache2 restart
fi

CHECK_GIT_CONFIG=$(cd /var/www/html && git config --get remote.origin.url)
if [ -z "$CHECK_GIT_CONFIG" ]
then
  echo "Mise en place config git"
  cd /var/www/html && rm -rf .git/
  git init
  git remote add origin https://github.com/Whmn777/piscine.git
fi

echo "Pull sources git"
cd /var/www/html
git pull origin master
composer install
chown -R www-data:www-data /var/www/html/
source .env.dev

echo "Configuration SSL / HTTPS"
certbot --apache -d helene.piscine.miicom.fr --redirect
