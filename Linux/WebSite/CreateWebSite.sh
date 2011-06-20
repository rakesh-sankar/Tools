#!/bin/sh
## This script creates a subdomain site for cosdevx.com
## Please use it with your own risk
##
## Author Rakesh Sankar (http://rakeshsankar.wordpress.com/)

# Make sure there are inputs
if [ $# -eq 0 ]
then
   echo "Usage: $0 <site-name>"
   exit 1
fi

# assign some variables
defaultSite="cosdevx.com"
defaultSitePath="/var/www/vhosts/"
website="$1.$defaultSite"

# System variables
apacheConf="/etc/httpd/conf.d/zz_costrategix.conf"
ownerName="rakesh"
webserver="apache"

# Make sure the argument is an alphanumeric
alphaNum="$(echo $1 | sed -e 's/[^[:alnum:]]//g')"

if [ "$alphaNum" != "$1" ]
then
   echo "Website $1 is invalid. It should be alphanumeric."
   exit 1
fi

# Virtual Host function
vhost() {
   # assign the sitename
   siteName=$1
   sitePathNm=$2

   vHostVar="\n<VirtualHost 74.208.79.145:80>\n\tServerName    $siteName\n\tServerAlias   *.$siteName\n\tDocumentRoot    ${defaultSitePath}${sitePathNm}/\n\t # following line needs the "with_vhost" log defined\n\tCustomLog ${defaultSitePath}${sitePathNm}/logs/access_logs combined\n\tErrorLog ${defaultSitePath}${sitePathNm}/logs/error_logs\n\t<Directory "${defaultSitePath}${sitePathNm}/">\n\t\tAllowOverride All\n\t\t<IfModule sapi_apache2.c>\n\t\t\tphp_admin_flag engine on\n\t\t</IfModule>\n\t\t<IfModule mod_php5.c>\n\t\t\tphp_admin_flag engine on\n\t\t</IfModule>\n\t</Directory>\n\t<IfModule dir_module>\n\t\tDirectoryIndex index.php index.php4 index.php3 index.cgi index.pl index.html index.htm index.shtml index.phtml\n\t</IfModule>\n</VirtualHost>"

   # dump vhost into a file
   echo -e $vHostVar >> $apacheConf
}

# create necessary folders
createSitePath() {
   # create folders for the site
   mkdir $defaultSitePath/$1
   mkdir $defaultSitePath/$1/logs

   # change the ownership
   chown -R $ownerName:$webserver $defaultSitePath/$1
}

# trigger apache
rstApache() {
   # Start apache gracefully
   /usr/sbin/apachectl -k graceful  
}

# create necessary folders
createSitePath $1

# create a vhost entry for the site
vhost $website $1

# start the web-server gracefully which does not impact others
rstApache

exit
