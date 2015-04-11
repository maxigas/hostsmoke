#!/bin/bash
# Write smokeping's Target file based on what we find in /etc/hosts, and leave a backup of the original Target file.
set -e
cp /etc/smokeping/config.d/Targets /etc/smokeping/config.d/Targets`date +%Y-%m-%d`
if [ -f /etc/smokeping/config.d/Header ];
then
    cp /etc/smokeping/config.d/Header /etc/smokeping/config.d/Targets
else
    echo 'You have to write the header of the target file in:
/etc/smokeping/config.d/Header'
    exit 1
fi
#grep -v '#' /etc/hosts|grep -vE '^$'|grep -v '::'|grep -v 'localhost'|awk '{print "++" $2 "\n title =" $2 "\n host =" $1 "\n"}'> /etc/smokeping/config.d/Targets
egrep -v '#|^$|::|localhost' /etc/hosts |awk '{print "++" $2 "\n title = " $2 "\n host = " $1 "\n"}'>> /etc/smokeping/config.d/Targets
