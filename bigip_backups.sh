#!/bin/bash
#Todays Date:
DATE=`date +"%m-%d-%y"`
mkdir -p ~/backups/

# Make and array of your bigips
declare -A BIGIPS
BIGIPS[GTM01]="172.24.130.86"
BIGIPS[GTM02]="172.24.130.87"
BIGIPS[LTM01]="172.24.130.88"
BIGIPS[LTM02]="172.24.130.89"

if [ "$1" == "setup" ]; then
  ssh-keygen -t rsa
  for i in "${!BIGIPS[@]}"
  do
    cat .ssh/id_rsa.pub | ssh root@${BIGIPS[$i]} 'cat >> /root/.ssh/authorized_keys'
  done
fi

  for i in "${!BIGIPS[@]}"
  do
    ssh root@${BIGIPS[$i]} -t 'tmsh save sys ucs /var/local/ucs/$HOSTNAME.`date +"%m-%d-%y"`.ucs'
    scp root@${BIGIPS[$i]}:/var/local/ucs/*`date +"%m-%d-%y"`.ucs ~/backups/
    ssh root@${BIGIPS[$i]} -t 'rm /var/local/ucs/*`date +"%m-%d-%y"`.ucs'
  done

# delete UCSs that are three weeks old.
find ~/backups/ -type f  -mtime +21 -exec rm {} \;
