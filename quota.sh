#!/bin/bash

partition1="/dev/mapper/openeuler-home"
partiition2="/dev/sda3"

mount_point1="/home"
mount_point2="/data"

# Activer usrquota et grpquota sur la partition si elles ne le sont pas encore
enable_quota(){
	sudo sed -i "s|defaults.*|defaults,usrquota,grpquota 1 2|g" /etc/fstab
	systemctl daemon-reload

	mount -o remount $mount_point1
	mount -o remount $mount_point2
	quotacheck -cufg $mount_point1
	quotacheck -cufg $mount_point2

	quotaon -uvg $mount_point1
	quotaon -uvg $mount_point2

}

# Mettre en place les quotas de chaque utilisateurs
set_quota_for_user(){	
	for user in $(ls $mount_point1); do
		sudo setquota -u $user 700M 0 0 0 $mount_point1 2>/dev/null
		sudo setquota -u $user 0 0 100000 0 $mount_point2 2>/dev/null
		sudo setquota -t 864000 0 $mount_point1 2>/dev/null
	done
}

# Mettre en place les quotas de chaques groupes
set_quota_for_group(){
	for group in $(awk -F ":" '{if ($3 >=1000 && $3<60000) print $1} /etc/group'); do
		setquota -g $group 0 0 100000 0 $mount_point2 2>/dev/null || true
	done
}

# Verifier le statut du quota
check_and_report(){
	for user in $(ls $mount_point1); do
		quota -u $user
		block=$(quota -u $user 2>/dev/null | tail -1 | awk '{print $1}')
		soft=$(quota -u $user 2>/dev/null | tail -1 | awk '{print $2}')

		if [ $block -gt $soft ]; then
			echo "You have exceeded your soft limit quota, your used block is $block" |mail -s "Quota excess $(date)" $user
		fi	
	done
}

if [ -z $(mount | grep -o "usrquota") ]; then
	echo "Make sure there is no process running on your mount point or else reboot your computer to apply changes"
	enable_quota
else
	set_quota_for_user
	check_and_report
fi

if [ -z $(grep -o "quota.sh" /etc/crontab) ]; then
	echo "* 12 * * * /quota.sh" >> /etc/crontab
fi
