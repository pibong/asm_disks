#!/bin/bash
#
# DESCRIPTION: show devices in Oracle asm diskgroups, making a relation between asm disks and multipath devices
# Tested with storage devices: 
# IBM,2145
# EMC,Invista
# HITACHI ,OPEN-V
# AUTHOR: Pietro Bongiovanni // piero.bongiovanni@gmail.com

TMPMP=/tmp/multipath_ll
TMPASM=/tmp/asmdisk
OPTION=$1

function usage()
{
        echo "usage: $0 [list|unused]"
}

function list_asm_disks_map()
{
	if [ ! -f /etc/init.d/oracleasm -o ! -f /sbin/multipath -o ! -d /dev/oracleasm/disks ]; then
		echo "multipathd and/or asm diskgroups are not used here!"
		exit 2
	fi

        if [ "$1" == "list" -o "$1" == "unused" ]
        then
                /sbin/multipath -ll > $TMPMP
        fi

        for ASMDISK in `/etc/init.d/oracleasm listdisks`
        do
                OUTPUT=`ls -l /dev/oracleasm/disks/$ASMDISK`
                MAJOR=`echo $OUTPUT|awk '{print $5}'`
                MINOR=`echo $OUTPUT|awk '{print $6}'`
                OSDISK=`ls -l /dev/dm-* |grep -P "$MAJOR[\s]+$MINOR " |awk '{print $10}'`
                if [ "$1" == "list" ]
                then
                        DEVICE=`basename $OSDISK`
                        MPATH=`grep "^.*$DEVICE .*$" $TMPMP | awk '{print $1" "$2" "$3}'`
                        #SIZE=`grep -A1 "^.*$DEVICE .*$" $TMPMP | grep size | cut -d[ -f2`
                        SIZE=`grep -A1 "^.*$DEVICE .*$" $TMPMP | grep size |awk '{print $1}'| cut -d'=' -f2`
                        echo "$ASMDISK = $MPATH $SIZE"
                elif [ "$1" == "unused" ]
                then
                        echo "$OSDISK" >> $TMPASM
                else
                        echo "$ASMDISK = $OSDISK"
                fi
        done

        if [ "$1" == "unused" ]
        then
                for DISK in `cat $TMPMP | grep mpath | awk '{print $3}' | xargs`
                do
                        UNLOCATED=$(grep "^.*$DISK$" $TMPASM)
                        if [ "$?" == "1" ]
                        then
                                MPATH=`grep "^.*$DISK .*$" $TMPMP | awk '{print $1" "$2" "$3}'`
                                SIZE=`grep -A1 "^.*$DISK .*$" $TMPMP | grep size | cut -d[ -f2`
                                echo "$MPATH [$SIZE"
                        fi
                done
        fi

        rm -f $TMPMP
        rm -f $TMPASM
}

function rescan_hba()
{
        echo "Scanning local HBA..."
        for HBA in `ls /sys/class/scsi_host/host?/scan`
        do
                echo "- - -" > $HBA
        done

        /sbin/multipath -v2

}

# Check if you are running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# Check argv
[ -z "$OPTION" ] && usage && exit 1

# Parse command value
case $OPTION
in
        list)
                list_asm_disks_map list
                ;;

        unused)
                list_asm_disks_map unused
                ;;

        *)
                usage
                exit 1
esac
