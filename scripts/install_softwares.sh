#!/bin/bash

sudo yum install -y java-1.8.0-openjdk
sudo yum install -y tomcat
sudo yum install tomcat-webapps tomcat-docs-webapp tomcat-admin-webapps -y
sudo chkconfig tomcat on
sudo service tomcat start
sudo sed -i 's!</tomcat-users>!<role rolename="admin"/>\n<role rolename="admin-gui"/>\n<role rolename="admin-script"/>\n<role rolename="manager"/>\n<role rolename="manager-gui"/>\n<role rolename="manager-script"/>\n<role rolename="manager-jmx"/>\n<role rolename="manager-status"/>\n<user name="admin" password="admin" roles="admin,manager,admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status" /> &!' /etc/tomcat/tomcat-users.xml
sudo mv hello.war /var/lib/tomcat/webapps/
sudo service tomcat restart
