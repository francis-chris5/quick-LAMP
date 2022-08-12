#!/bin/bash

			############################################
			##                                        ##
			##   This is a replica of the LAMP stack  ##
			##   I like to use on AWS and GCP server  ##
			##   instances on WSL2 Ubuntu for testing ##
			##   before deployment.                   ##
			##                                        ##
			##   In home directory of a fresh Ubuntu  ##
			##   install, create a wsl-LAMP directory ##
			##   containing this and the test files   ##
			##   included with it.                    ##
			##                                        ##
			##   Then run this script...              ##
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
sudo chmod 666 /etc/apache2/sites-available/000-default.conf


	## modify apache2.conf 
sudo sed -i '228s/.*/ /' /etc/apache2/apache2.conf
echo "Options +ExecCGI" >> /etc/apache2/apache2.conf
echo "AddHandler cgi-script .py" >> /etc/apache2/apache2.conf

	## modify serve-cgi-bin.conf
sudo sed -i '11s/.*/\t\tScriptAlias \/python\/ \/var\/www\/html\/python\//' /etc/apache2/conf-available/serve-cgi-bin.conf
sudo sed -i '12s/.*/\t\t<Directory \/var\/www\/html>/' /etc/apache2/conf-available/serve-cgi-bin.conf
sudo sed -i '13s/.*/\t\t\tAllowOverride None/' /etc/apache2/conf-available/serve-cgi-bin.conf
sudo sed -i '14s/.*/\t\t\tOptions +ExecCGI/' /etc/apache2/conf-available/serve-cgi-bin.conf

	## modify 000-default.conf
sudo sed -i '29s/.*/ /' /etc/apache2/sites-available/000-default.conf
sudo sed -i '31s/.*/ /' /etc/apache2/sites-available/000-default.conf
echo "    <directory /var/www/html/python>" >> /etc/apache2/sites-available/000-default.conf
echo "        DirectoryIndex index.html index.py" >> /etc/apache2/sites-available/000-default.conf
echo "    </directory>" >> /etc/apache2/sites-available/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf
echo " " >> /etc/apahce2/sites-available/000-default.conf
echo "# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" >> /etc/apache2/sites-available/000-default.conf
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

	## modify tomcat-users.xml configuration file so there's a default manager and admin users
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



		### can't seem to make services on WSL 
			## has to be set as a task on windows system, not sure how to do that from this script
			## at least make it a single command for now: sudo lamp
echo "#!/bin/bash" > lamp-start.sh
echo "" >> lamp-start.sh
echo "sudo service apache2 start" >> lamp-start.sh
echo "sudo /etc/init.d/mysql start" >> lamp-start.sh
echo "sudo /opt/tomcat/bin/startup.sh" >> lamp-start.sh

sudo cp lamp-start.sh /etc/apache2/lamp-start.sh
sudo rm lamp-start.sh
sudo chmod 755 /etc/apache2/lamp-start.sh

sudo echo "alias lamp=\"/etc/apache2/lamp-start.sh\"" >> ~/.bashrc


	## it can be very useful to have the IP addresses readily avalailable
echo "" >> ~/.bashrc	
echo "" >> ~/.bashrc	
echo "export apacheIP=\$(/sbin/ip -o -4 addr list eth0 | awk '{print \$4}' | cut -d/ -f1)" >> ~/.bashrc
echo "export tomcatIP=\$(/sbin/ip -o -4 addr list eth0 | awk '{print \$4}' | cut -d/ -f1):8080" >> ~/.bashrc

	## since testing ajax (without using port# in URL) requires the javascript to know the actual ip address
		## set first line in javascript to: var localIP="http:123.123.123.123;", this script changes it for dynamic IP addresses, like on wsl
		## after opening bash terminal and running "lamp" created above, run the command "updateIP" (must uncomment in .bashrc)	
echo "#!/bin/bash" > updateIP.sh
echo "" > updateIP.sh
echo "sudo sed -i '1s/.*/var localIP=\"http:\/\/'\$1'\";/' \$2" >> updateIP.sh
sudo cp updateIP.sh /var/www/updateIP.sh 
sudo rm updateIP.sh
sudo chmod 755 /var/www/updateIP.sh

	## this dynamically changes the ip address the javascript ajax functions make requests to: must set first line in javascript file to a global variable holding this server's ip address (see example .js file in wsl-LAMP folder)
	## one project at a time, so the command will need modified to the filepath of the current project
echo "" >> ~/.bashrc
echo "" >> ~/.bashrc
echo "### after adding an javascript file containing ajax copy this command and add the filepath to the javascript file" >> ~/.bashrc
echo "### make sure the first line in the javascript file looks like: var localIP=\"http://172.22.188.197\"; and then use that variable in the ajax request address" >> ~/.bashrc
echo "# alias updateIP=\"sudo /var/www/updateIP.sh \$apacheIP [filepath to .js with ajax]\"" >> ~/.bashrc



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
cp ~/wsl-LAMP/index.py /var/www/html/python/


	## restart both servers
sudo service apache2 restart
sudo /opt/tomcat/bin/shutdown.sh
sudo /opt/tomcat/bin/startup.sh


## WSL: put the IP address of this machine in a broswer (not localhost)
## tomcat is on port 8080, manager app at ipAddress:8080/tomcat
## python scripts run from ipAddress/python/scriptName.py





####################  END OF SCRIPT  #################
