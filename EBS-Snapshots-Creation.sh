
#!/bin/bash

# This script will create snapshots of all EBS volumes as well as delete those it has created that are older than 3 days. It will not delete snapshots attached to AMI's that need them.

# Create a unique snapshot tag
echo "Snapshot-Date-`date +%d%b%y`" > /tmp/aminame.txt

# Get account volume Id's
volumeid=$(aws ec2 describe-volumes --region us-east-1 |  grep VolumeId | sed 's/"\|:\|,\|VolumeId\| //g' | awk '!seen[$0]++' )

# Loop through the Volume Id's
count=1
for j in $volumeid; do

# Retrieve the current tag
tag=$(aws ec2 describe-volumes --region us-east-1 --volume-id $j --filter Name=tag-key,Values=Name | grep Value | sed 's/"\|:\|,\|Value\| //g')

echo Volume \#$count
echo ________________________________
echo
echo Creating Snapshot of Volume $j

# Create the snapshots
snapcopy=$(aws ec2 create-snapshot --region us-east-1 --volume-id $j | grep "SnapshotId" | sed 's/"\|,\|:\|^[ \t]*\|\|SnapshotId//g')

echo
echo Waiting for the snapshot to create

# Wait for the snapshot
aws ec2 wait --region us-east-1  snapshot-completed --snapshot-ids $snapcopy

echo Transfering tags
# Tag it with original Name tag and add the custom tag from this script
aws ec2 create-tags --region us-east-1 --resources $snapcopy --tags Key=Name,Value=$tag
aws ec2 create-tags --region us-east-1 --resources $snapcopy --tags Key=Backup-Date,Value=`cat /tmp/aminame.txt`

echo Getting next snapshot
(( count++ ))

done

((count--))
created=$count

######## Delete Snapshots Older Than 3 Days ########

# Finding snapshots older than 3 days which needed to be removed
echo "Snapshot-Date-`date +%d%b%y --date '3 days ago'`" > /tmp/amidel.txt

#Finding snaphots that need to be deleted
fordelete=$(aws ec2 describe-snapshots --region us-east-1 --filters "Name=owner-id,Values=404119222964" | grep -A 15 `cat /tmp/amidel.txt` | grep "SnapshotId" | sed 's/"\|,\|:\|SnapshotId\|^ *//g')

count=1
for i in $fordelete; do

echo Snapshot \#$count
echo ________________________________

echo
echo -e "Deleting $i ... \n"

#Deleting the snapshot
aws ec2 delete-snapshot --region us-east-1 --snapshot-id $i

echo Getting next snapshot marked for deletion
((count++))

done

# Clean Up

rm -rf amidel.txt aminame.txt imageid.txt
echo
echo
echo Success! We created $created snapshots.
echo and deleted all snapshots older than 3 days, except those attached to an AMI that needs them.