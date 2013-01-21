#!/bin/bash
#
# Testcase 1: array start & shutdown
#

. ./monitor_testcase_functions.sh

MD_NUM="md1"
MD_NAME="testcase1"
DEVNOS_LEFT="0.0.0210 0.0.0211 0.0.0212 0.0.0213"
DEVNOS_RIGHT="0.0.0220 0.0.0221 0.0.0222 0.0.0223"

logger "Monitor Testcase 1: Array startup/shutdown"

stop_md $MD_NUM

activate_dasds

clear_metadata

ulimit -c unlimited
start_md ${MD_NUM}

echo "Create filesystem ..."
if ! mkfs.ext3 /dev/${MD_NUM} ; then
    error_exit "Cannot create fs"
fi
sleep 1
echo "Mount filesystem ..."
if ! mount /dev/${MD_NUM} /mnt ; then
    error_exit "Cannot mount MD array."
fi

echo "Write test file ..."
dd if=/dev/zero of=/mnt/testfile1 bs=4096 count=1024
sleep 5
echo "Umount filesystem ..."
umount /mnt
echo "Stop MD array ..."
mdadm --stop /dev/${MD_NUM}
echo "Reassemble MD array ..."
mdadm --assemble /dev/${MD_NUM}
mdadm --wait /dev/${MD_NUM}
mdadm --detail /dev/${MD_NUM}

echo "Remount filesystem ..."
if ! mount /dev/${MD_NUM} /mnt ; then
    error_exit "Cannot re-mount MD array."
fi

ls -l /mnt
sleep 5

echo "Umount filesystem ..."
umount /mnt

stop_md ${MD_NUM}
