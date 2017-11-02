# usefulshellscripts


### Delete Available Volumes
This script deletes all available (unattached) volumes in an AWS account.


### Encrypt Snapshots
This script will encrypt all unencrypted snapshots in an AWS account. You can uncomment the 'Delete unencrypted snapshot' line if you'd like, but it will not delete snapshots attached to AMI's.

### EBS-Snapshots-Creation
This script will search for all volumes in the account and create a snapshot of them. It will move the existing tag to the snapshot and also apply a custom tag that this script will use to track and rotate snapshots. When this script is run, it will delete snapshots that it has created that are older than 3 days. The only snapshots it will not delete are those that belong to an AMI that needs them. 
