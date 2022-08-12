#!/bin/bash

sudo service apache2 start
sudo /etc/init.d/mysql start
sudo /opt/tomcat/bin/startup.sh
