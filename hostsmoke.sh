#!/bin/bash
# Write smokeping's Target file based on suk:/etc/hosts, leave a backup of the original Target file in omnius:/home/hostsmoke/config.d/.
set -e
# Get the necessary files from the router (suk.calafou) and the media server (omnius.calafou) -- requirement is to be on the Calafou local network, have local DNS and key-based authentication set up for SSH
mkdir -pv files
rm -rfv files/*
scp omnius.calafou:/home/hostsmoke/config.d/Header files
scp omnius.calafou:/home/hostsmoke/config.d/Targets files
scp suk:/etc/hosts files
# Backup
cp -v files/Targets files/Targets`date +%Y-%m-%d`
scp files/Targets`date +%Y-%m-%d` omnius.calafou:/home/hostsmoke/config.d/
# Write header
if [ -f files/Header ];
then
    cp -v files/Header files/Targets
else 
    echo 'You have to write the header of the target file in:
omnius.calafou:/home/hostsmoke/config.d/Header'
    exit 1
fi
# Throw away comments, IPv6 and localhost entries and write Targets file
egrep -v '#|^$|::|localhost' files/hosts | awk '{print "++" $2 "\n title = " $2 "\n host = " $1 "\n"}'>> files/Targets
# Avoid invalid smokeping syntax: remove dots from section names
sed -i 's/\(++.*\)\.\(.*\)/\1\2/g' files/Targets
# Deploy Targets
scp files/Targets omnius.calafou:/home/hostsmoke/config.d/Targets
# Restart service to generate newly added .rrd files
ssh omnius.calafou sudo service smokeping restart
# Output status check to verify that things went well
ssh omnius.calafou sudo service smokeping status
# Launch browser to check results
/etc/alternatives/www-browser "http://omnius.calafou/smokeping/smokeping.cgi?target=Calafou"
