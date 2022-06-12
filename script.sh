#!/bin/bash
#
# Go to root
cd /
#
# Init var
OS=`uname -p`;
#
# Init domain name
read -p "Enter Domain Name : " domain_name
# Disable SELinux
sudo echo 0 > /selinux/enforce
sudo sed -i 's/SELINUX=enforcing/SELINUX=disable/g'  /etc/sysconfig/selinux
#
# Disable ipv6
sudo echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sudo sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
sudo sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.d/rc.local
#
# Set locale
sudo sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
sudo service sshd restart
#
# Remove unused
sudo yum remove -y sendmail;
sudo yum remove -y httpd;
sudo yum remove -y cyrus-sasl
#
# Update
sudo yum update -y
#
# Upgrade
sudo yum upgrade -y
#
# Install Extra Packages for Enterprise Linux
sudo yum install -y epel-release
#
# Install collection of tools and programs for managing
sudo yum install -y yum-utils
#
# Install Development Tools
sudo yum group install -y "Development Tools"
#
# set time GMT +7
ln -fs /usr/share/zoneinfo/Europe/Kiev /etc/localtime
#
#Install docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo;
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin;
sudo systemctl start docker;
sudo systemctl enable docker;
sudo systemctl status docker
#
# Make work directory 
sudo mkdir /opt/stream;
cd /opt/stream
#
# Clone git repository
sudo git clone https://github.com/icrazystreamer/docker-nginx-rtmp-ssl.git
#
# Enter to folder of repository
cd docker-nginx-rtmp-ssl
#
# Insert Domain Name into nginx.conf
sed -i "s/DOMAIN_NAME/${domain_name}/g" nginx.conf
#
# Start Docker compose
sudo docker compose up -d
#
#
sudo docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d $domain_name
#
# Testing
if [ $? -eq 0 ]
then
  echo "Successfully test"
  exit 0
else
  echo "Test not pass. Check config" >&2
  exit 1
fi
#
#Get a certificate
sudo docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ -d $domain_name
#
# Remove rem
sed -i 's/^#.//g' nginx.conf
#
#Restart Docker compose
sudo docker compose restart
#
# Info
clear
echo "How to work:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Stream live content to : rtmp://$domain_name:1935/stream/<STREAM_NAME>" | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "Player in your browser : https://$domain_name/player.html?url=https://$domain_name/stream/<STREAM_NAME>.m3u8"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "In Safari, VLC or any HLS player : https://$domain_name/stream/<STREAM_NAME>.m3u8" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt



















