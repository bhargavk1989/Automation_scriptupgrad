#!/bin/bash
s3_bucket="upgrad-bhargav"
myname="bhargav"
apt-get update -y 1>/dev/null

check=$(apt list apache2 2>/dev/null | grep 'installed' | wc -l)
if [ $check -eq 0 ]
then
	apt-get install apache2 -y
fi
check=$(apt list awscli 2>/dev/null | grep 'installed' | wc -l)
if [ $check -eq 0 ]
then
	apt-get install awscli -y
fi
apac=$(ls -l /var/run/apache2 | wc -l)
if [ $apac -eq 0 ]
then
	apache2 -k start
	sudo update-rc.d apache2 defaults
fi
tstamp=$(date "+%d%m%Y-%H%M%S")
cd /var/log/apache2
tar -cf $myname-httpd-logs-$tstamp.tar *
cp $myname-httpd-logs-$tstamp.tar /tmp
aws s3 cp /tmp/$myname-httpd-logs-$tstamp.tar s3://$s3_bucket/ 1>/dev/null
if [ ! -f /var/www/html/inventory.html ]
then
	awk 'BEGIN{print "<pre>","<a>Log Type</a>\t","<a>Date Created</a>\t\t\t","<a>Type</a>\t","<a>Size</a>","<pre>"}' > /var/www/html/inventory.html
	ls -lr $myname-httpd-logs-$tstamp.tar | awk -v myname1="$tstamp" '{gsub(/.tar/, "")};{print "<a>httpd-logs<a>\t","<a>"myname1"</a>\t\t","<a>"$5/1024 "K</a>\t","<a>tar</a>"}' >> /var/www/html/inventory.html
else
	ls -lr $myname-httpd-logs-$tstamp.tar | awk -v myname1="$tstamp" '{gsub(/.tar/, "")};{print "<a>httpd-logs<a>\t","<a>"myname1"</a>\t\t","<a>"$5/1024 "K</a>\t","<a>tar</a>"}' >> /var/www/html/inventory.html
fi
rm -f $myname-httpd-logs-$tstamp.tar	
if [ ! -f /etc/cron.d/automation ]
then
	echo "0 12 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi
echo "Operation Completed"

