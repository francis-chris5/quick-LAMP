#!/bin/bash

sudo apt update
sudo apt upgrade -y

sudo apt install apache2 php libapache2-mod-php -y
sudo service apache2 start

sudo apt install mariadb-server php-mysql -y
sudo service mariadb start

sudo apt install php-bz2 php-gd php-curl -y
sudo apt install phpmyadmin -y

sudo mysql -Bse "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';"
sudo mysql -Bse "GRANT ALL PRIVILEGES on *.* TO 'admin'@'localhost' WITH GRANT OPTION;"
sudo mysql -Bse "CREATE USER 'webpage'@'localhost' IDENTIFIED BY 'webpage';"
sudo mysql -Bse "GRANT SELECT, INSERT ON *.* TO 'webpage'@'localhost' WITH GRANT OPTION;"

