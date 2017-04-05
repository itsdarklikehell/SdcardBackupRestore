#!/bin/bash

echo ",------.                       ,--.   ,--.                 "
echo "|  .--. ' ,--,--. ,---.  ,---. |  |-. \`--' ,--,--.,--,--,  "
echo "|  '--'.'' ,-.  |(  .-' | .-. || .-. ',--.' ,-.  ||      \\"
echo "|  |\  \ \ '-'  |.-'  \`)| '-' '| \`-' ||  |\ '-'  ||  ||  | "
echo "\`--' '--' \`--\`--'\`----' |  |-'  \`---' \`--' \`--\`--'\`--''--' "
echo "                        \`--'                              "

## (verry expirimental!) I have made an option to mount an .gz as a loop device for viewing and/or editing before restore.

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' dialog|grep "install ok installed")

# Read all the disks
ARRAY_DISK=$(fdisk -l 2>/dev/null | grep "Disk /dev" | awk  '{ print $2 }' | sed 's/://g')


function do_backup
{
	# Make a menu
	createmenu ${ARRAY_DISK}
	echo "  "
	DISK=${option}
	FILE=raspbian_backup_image`date +%d%m%y`.gz
	echo "Starting backup, this may take a long time.... just wait please!"
	sudo dd bs=4M if=${DISK} | gzip > raspbian_backup_image`date +%d%m%y`.gz
	echo "Backup done and saved with file ${FILE}"
	echo "Bye!"
	exit 0
}

function do_restore
{
	# Make a menu
	createmenu ${ARRAY_DISK}
	echo "  "
	DISK=${option}
	echo  "What is the full path to the .gz file to restore?"
	read FILE


	read -p "Are you sure you want to restore the image ${FILE} to the ${DISK}? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		echo "User aborted operation!"
    	exit 1
	fi
	read -p "Are you really really sure you want to restore the image ${FILE} to the ${DISK}? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		echo "User aborted operation!"
    	exit 1
	fi

	echo "Starting restore, this may take a long time.... just wait please!"
    sudo gzip -dc ${FILE} | dd bs=4M of=${DISK}  status=progress
	echo "Restore done and saved with file ${FILE}"
	echo "Bye!"
	exit 0
}
function do_mount() {
	echo  "What is the full path to the .gz file to mount?"
	read FILE
	echo "where would you like to mount this e.g.  /mnt/USB_image"
	read LOCATION
	mount ${FILE} ${LOCATION} -o loop
	echo "Mountpoint created ${LOCATION} from ${FILE}"
	echo "Bye!"
	exit 0
}
function do_umount() {
	echo "where did you mount this? e.g. /mnt/USB_image"
	read LOCATION
	umount ${LOCATION}
	echo "Mountpoint ${LOCATION} unmounted"
	echo "Bye!"
	exit 0
}
function createmenu ()
{
  select option; do # in "$@" is the default
    if [ "$REPLY" -eq "$#" ];
    then
      echo "Exiting..."
      break;
    elif [ 1 -le "$REPLY" ] && [ "$REPLY" -le $(($#-1)) ];
    then
      echo "You selected $option which is option $REPLY"
      break;
    else
      echo "Incorrect Input: Select a number 1-$#"
    fi
 done

}
PS3='Do you want to backup or restore an sdcard or do you want to mount or unmount an backup? '
options=("Backup" "Restore" "Mount" "Unmount" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Backup")
            echo "Backup..."
            echo " "
	    	do_backup
            ;;
        "Restore")
            echo "Restore..."
            echo " "
	    	do_restore
            ;;
				"Mount")
		        echo "Mount..."
		        echo " "
			  do_mount
		        ;;
				"Unmount")
		        echo "Unmount..."
		        echo " "
			  do_unmount
		        ;;
				"Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
