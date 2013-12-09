#!/bin/sh
# Based on the rowboat packaging script
if [[ $# -ne 2 ]]; then
    echo "This utility creates a bootable microSD card for Android."
    echo "Usage: $0 <sd-drive> <product-name>"
    echo "Example:"
    echo "	sudo out/host/linux-x86/bin/mkcard /dev/mmcblk0 overo"
    exit -1
fi

#=== Setup variables ===
OUTDIR="out/target/product/$2"
BOOTDIR="$OUTDIR/boot"
SYSTEM="system.tar.bz2"
DATA="userdata.tar.bz2"

#==== Check files ===
if ! [[ -e ${BOOTDIR} ]]; then
	echo "No ${BOOTDIR} found! Quitting..."
	exit -1
fi
if ! [[ -e ${OUTDIR}/${SYSTEM} ]]; then
	echo "No ${SYSTEM} found! Quitting..."
	exit -1
fi
if ! [[ -e ${OUTDIR}/${DATA} ]]; then
	echo "No ${DATA} found! Quitting..."
	exit -1
fi

echo -n "All data on "$1" now will be destroyed! Continue? [y/n]: "
read ans
if ! [ $ans == 'y' ]; then
	exit
fi

echo "[Unmounting all existing partitions on the device ]"
umount $1* &> /dev/null

echo "[Partitioning $1...]"
DRIVE=$1
dd if=/dev/zero of=$DRIVE bs=1024 count=1024 &>/dev/null
# 64MB VFAT boot partition, 1GB EXT4 system partition, 1GB EXT4 cache partition, remainder is EXT4 data partition
# Sector size is 512-bytes
{
echo 128,130944,0x0C,*
echo 131072,2097152,,-
echo 2228224,2097152,,-
echo 4325376,,,-
} | sfdisk --force -D -uS -H 255 -S 63 $DRIVE &> /dev/null

echo "[Making boot partition...]"
if [ -b ${1}1 ]; then
    mkfs.vfat -F 32 -n boot "$1"1 &> /dev/null
    mount "$1"1 /mnt
else
    mkfs.vfat -F 32 -n boot "$1"p1 &> /dev/null
    mount "$1"p1 /mnt
fi
cp -v ${BOOTDIR}/* /mnt/
umount /mnt

echo "[Making system partition...]"
if [ -b ${1}2 ]; then
    mkfs.ext4 -L system "$1"2 &> /dev/null
    mount "$1"2 /mnt
else
    mkfs.ext4 -L system "$1"p2 &> /dev/null
    mount "$1"p2 /mnt
fi
tar jxvf ${OUTDIR}/${SYSTEM} --strip-components=1 -C /mnt &> /dev/null
sync
umount /mnt

echo "[Making cache partition...]"
if [ -b ${1}3 ]; then
    mkfs.ext4 -L cache "$1"3 &> /dev/null
    mount "$1"3 /mnt
else
    mkfs.ext4 -L cache "$1"p3 &> /dev/null
    mount "$1"p3 /mnt
fi
sync
umount /mnt

echo "[Making data partition]"
if [ -b ${1}4 ]; then
    mkfs.ext4 -L data "$1"4 &> /dev/null
    mount "$1"4 /mnt
else
    mkfs.ext4 -L data "$1"p4 &> /dev/null
    mount "$1"p4 /mnt
fi
tar jxvf ${OUTDIR}/${DATA} --strip-components=1 -C /mnt &> /dev/null
sync
umount /mnt

echo "[Done]"
