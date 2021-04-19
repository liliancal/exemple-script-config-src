#!/bin/bash

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

