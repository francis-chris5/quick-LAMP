#!/bin/bash

			############################################
			##                                        ##
			##   This is the LAMP stack I like to     ##
			##   use on AWS and GCP server instances  ##
			##   as well as on WSL2 for an identical  ##
			##   test environment as it will be       ##
			##   deployed to.                         ##
			##                                        ##
			##   In home directory create wsl-LAMP    ##
			##   directory containing this and three  ##
			##   test files included with it, or      ##
			##   comment out lines in Test Case       ##
			##   section. Then run this script...     ##
			##                                        ##
			############################################

## tested on WSL2 with Ubuntu 20.0.4


sudo apt update
sudo apt upgrade -y


##########################################
##                                      ##
##    install the tradtional LAMP       ##
##         (apache2, mariaDB, PHP)      ##
##                                      ##
##########################################

	
	# Apache and PHP
sudo apt install apache2 php libapache2-mod-php -y
sudo service apache2 start
sudo service apache2 enable

	## install and start mariadb 
sudo apt install mariadb-server php-mysql -y
sudo /etc/init.d/mysql start

	## install phpmyadmin application
sudo apt install php-bz2 php-gd php-curl -y
sudo apt install phpmyadmin -y

	
	## change to read/write permission for everyone on a couple config files
	## modify a couple of config files for phpmyadmin application
sudo chmod 666 /etc/php/*/apache2/php.ini
sudo chmod 666 /etc/apache2/apache2.conf
echo "extension=mysqli" >> /etc/php/*/apache2/php.ini
echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

sudo service apache2 restart

	### NOTES: 
		### still need to add a user to mysql in the terminal for phpmyadmin
		### replace user-> admin and password-> admin123 with something reasonable
			## $ sudo mysql
sudo mysql -Bse "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';"
sudo mysql -Bse "GRANT ALL PRIVILEGES on *.* TO 'admin'@'localhost' WITH GRANT OPTION;"

		### still need to add a restricted user to the database for webpage usage
			## $ sudo mysql
sudo mysql -Bse "CREATE USER 'webpage'@'localhost' IDENTIFIED BY 'webpage';"
sudo mysql -Bse "GRANT SELECT, INSERT ON *.* TO 'webpage'@'localhost' WITH GRANT OPTION;"
			## mysql> CREATE USER 'webwrite'@'localhost' IDENTIFIED BY 'WebAccess';
			## mysql> GRANT INSERT ON *.* TO 'webwrite'@'localhost' WITH GRANT OPTION;

		### I like to change the permissions on /var/www/html folder before putting anything in it to give regular users read/write access
			## chose not to do that in this script though





##########################################
##                                      ##
##    add Python3 to run CGI scripts    ##
##                                      ##
##########################################

	## enable cgi and create a directory for python scripts
		## I like to put them with other web site stuff
sudo a2enmod cgid
mkdir /var/www/html/python

	## modify a couple config files to allow cgi scripts in the directory just created
sudo chmod 666 /etc/apache2/apache2.conf
sudo chmod 666 /etc/apache2/conf-available/serve-cgi-bin.conf


	## modify apache2.conf 
echo "Options +ExecCGI" >> /etc/apache2/apache2.conf
echo "AddHandler cgi-script .py" >> /etc/apache2/apache2.conf

	## modify serve-cgi-bin.conf
sudo sed -i '11s/.*/\t\tScriptAlias \/python\/ \/var\/www\/html\/python\//' /etc/apache2/conf-available/serve-cgi-bin.conf
sudo sed -i '12s/.*/\t\t<Directory \/var\/www\/html>/' /etc/apache2/conf-available/serve-cgi-bin.conf
sudo sed -i '13s/.*/\t\t\tAllowOverride None/' /etc/apache2/conf-available/serve-cgi-bin.conf
sudo sed -i '14s/.*/\t\t\tOptions +ExecCGI/' /etc/apache2/conf-available/serve-cgi-bin.conf


	### NOTES:
		### if on a WSL Ubuntu system for test environment remember that windows linebreaks won't work in python script run in Linux




##########################################
##                                      ##
##    put Tomcat on there to run        ##
##          Java Applications           ##
##                                      ##
##########################################


	## install java
sudo apt install default-jdk -y

	## get the source files, unzip, rename, and move to a permenant directory 
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz
sudo tar -xvzf apache-tomcat-9.0.65.tar.gz
sudo mv apache-tomcat-9.0.65 tomcat
sudo mv tomcat /opt/
sudo rm apache-tomcat-9.0.65.tar.gz

	## open up port 8080 for tomcat to use
sudo ufw allow 8080

	## just give a bunch of access to tomcat files
		## need to refine this
sudo chmod 765 /opt/tomcat/*

	## modify tomcat-users.xml configuration file
sudo sed -i '56s/.*/<role rolename="manager-gui"\/>/' /opt/tomcat/conf/tomcat-users.xml
sudo chmod 666 /opt/tomcat/conf/tomcat-users.xml
sudo echo "<user username=\"tomcat\" password=\"tomcat\" roles=\"manager-gui\"/>" >> /opt/tomcat/conf/tomcat-users.xml
sudo echo "" >> /opt/tomcat/conf/tomcat-users.xml
sudo echo "<role rolename=\"admin-gui\"/>" >> /opt/tomcat/conf/tomcat-users.xml
sudo echo "<role rolename=\"admin-script\"/>" >> /opt/tomcat/conf/tomcat-users.xml
sudo echo "<user username=\"admin\" password=\"admin\" roles=\"admin-gui,admin-script\"/>" >> /opt/tomcat/conf/tomcat-users.xml
sudo echo "</tomcat-users>" >> /opt/tomcat/conf/tomcat-users.xml


	## modify context.xml configuration file
sudo sed -i '21s/.*/<!-- deleted local valve from config -->/' /opt/tomcat/webapps/manager/META-INF/context.xml
sudo sed -i '22s/.*/<!-- deleted local valve from config -->/' /opt/tomcat/webapps/manager/META-INF/context.xml


	 	### I also like to move all of the default page(s) and pictures for tomcat into a subdirectory of /opt/tomcat/webapps/ROOT and then make my own non-admin sort of index.jsp page
sudo mkdir /opt/tomcat/webapps/ROOT/tomcat

sudo mv /opt/tomcat/webapps/ROOT/asf-logo-wide.svg /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/bg-button.png /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/bg-middle.png /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/bg-nav.png /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/bg-upper.png /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/favicon.ico /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/index.jsp /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/tomcat.css /opt/tomcat/webapps/ROOT/tomcat/
sudo mv /opt/tomcat/webapps/ROOT/tomcat.svg /opt/tomcat/webapps/ROOT/tomcat/

	##start tomcat
sudo /opt/tomcat/bin/shutdown.sh
sudo /opt/tomcat/bin/startup.sh


	### NOTES:
		### I did not enable tomcat to start automatically yet
		### run those two commands just above this comment to start it






##########################################
##                                      ##
##             TEST CASES               ##
##        .php, .py, and .jsp           ##
##                                      ##
##########################################

### I like to do this stuff as well, 
### uses test files included with this bash script
sudo chmod 777 /var/www/html
mkdir /var/www/html/python
mkdir /var/www/html/php

sudo chmod 777 /opt/tomcat/webapps/ROOT
cp ~/wsl-LAMP/index.jsp /opt/tomcat/webapps/ROOT/

cp ~/wsl-LAMP/index.php /var/www/html/php/
cp ~/wsl-LAMP/hello.py /var/www/html/python/


	## restart both servers
sudo service apache2 restart
sudo /opt/tomcat/bin/shutdown.sh
sudo /opt/tomcat/bin/startup.sh


## WSL: put the IP address of this machine in a broswer (not localhost)
## tomcat is on port 8080, manager app at ipAddress:8080/tomcat
## python scripts run from ipAddress/python/scriptName.py





####################  END OF SCRIPT  #################
