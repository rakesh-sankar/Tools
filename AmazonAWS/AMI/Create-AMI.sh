#!/bin/bash

#Create the server image filename and manifest filename with todays date
imagename=prd-apache-php-svn-mysql-svn-sendmail-64bit
imagefile=$imagename.$(date +%d.%m.%Y)
manifest=$imagename.$(date +%d.%m.%Y).manifest.xml

#Create $short variable for deleting the files from the /mnt/ directory after bundling, this should be the first part of your imagename, that appears exactly the same throughout the files, for example, if your imagename is MyImageName, your $short variable should be set to MyImage, to account for any change in the filenames produced during bundling.
short=somename

#Create variables for your EC2 Private Key and Certificate files, edit the path and filenames appropriately
privatekey=/path/to/private-key
certificate=/path/to/certificate-file
#Create variable for your S3 userid
s3userid=<aws-account-number>

#Create variable for your bucketname
bucketname=<s3-bucket-name>

#Create variables for your S3 Access and Private Keys
s3accesskey=<aws-access-key>
s3privatekey=<aws-private-key>

#Create variable for JAVA_HOME, this is the location of your java executable folder, i.e. /usr/lib/jvm/java-1.5.0-sun-1.5.0.19/
javahome=/usr/lib/jvm/java-6-sun/jre/

#Create variable for EC2_HOME, this is the location of your ec2 tools folder, i.e. /root/ec2-api-tools
ec2home=$EC2_HOME

#Create the $excludes variable to be inserted into the bundle command, this prevents these folders from being included in the bundle operation if they are not vital to the AMI you wish to produce. To stop this behaviour simply remove the $excludes variable from the ec2-bundle-vol command below
excludes=/proc

#bundle the server, upload it, export necessary variables and register it,
ec2-bundle-vol -d /mnt -k $privatekey -c $certificate -u $s3userid -r x86_64 -p $imagefile && ec2-upload-bundle -b $bucketname -m /mnt/$manifest -a $s3accesskey -s $s3privatekey && export JAVA_HOME=$javahome && export EC2_HOME=$ec2home && export PATH=$PATH:$EC2_HOME/bin && export EC2_PRIVATE_KEY=$privatekey && export EC2_CERT=$certificate && ec2-register -n $bucketname-prd -K $privatekey -C $certificate $bucketname/$manifest

#delete the bundle files from the /mnt directory
rm -Rf /mnt/$short*
