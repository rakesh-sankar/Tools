#!/bin/bash

# export EC2_HOME='/etc/ec2'  # Make sure you use the API tools, not the AMI tools
# export EC2_BIN=$EC2_HOME/bin
# export PATH=$PATH:$EC2_BIN
# I know all of the above is good to have solution, but not re-usable
# I have captured all of the above in a particular file and lemme execute it
source /etc/environment

PURGE_SNAPSHOT_IN_DAYS=10

EC2_BIN=$EC2_HOME/bin

# Make sure the IAM user has only permission to create/delete snapshot and read the ec2 instances.
# The policy should look like this:
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "Stmt1425915805000",
#      "Effect": "Allow",
#      "Action": [
#          "ec2:CreateSnapshot",
#          "ec2:DeleteSnapshot",
#          "ec2:DescribeInstances"
#      ],
#      "Resource": [
#          "*"
#      ]
#    }
#  ]
#}

MY_ACCESS='IAM-SPECIFIC-ACCESS-KEY'
MY_SECRET='IAM-SPECIFIC-SECRETE-KEY'
# fetching the instance-id from the metadata repository
MY_INSTANCE_ID='your ec2-instance-id'

# temproary file
TMP_FILE='/tmp/rock-ebs-info.txt'

# get list of locally attached volumes via EC2 API:
$EC2_BIN/ec2-describe-volumes -O $MY_ACCESS -W $MY_SECRET > $TMP_FILE
VOLUME_LIST=$(cat $TMP_FILE | grep ${MY_INSTANCE_ID} | awk '{ print $2 }')

sync

#create the snapshots
echo "Create EBS Volume Snapshot - Process started at $(date +%m-%d-%Y-%T)"
echo ""
echo $VOLUME_LIST
for volume in $(echo $VOLUME_LIST); do
   NAME=$(cat $TMP_FILE | grep Name | grep $volume | awk '{ print $5 }')
   DESC=$NAME-$(date +%m-%d-%Y)
   echo "Creating Snapshot for the volume: $volume with description: $DESC"
   echo "Snapshot info below:"
   $EC2_BIN/ec2-create-snapshot -O $MY_ACCESS -W $MY_SECRET -d $DESC $volume
   echo ""
done

echo "Process ended at $(date +%m-%d-%Y-%T)"
echo ""

rm -f $TMP_FILE

#remove those snapshot which are $PURGE_SNAPSHOT_IN_DAYS old
