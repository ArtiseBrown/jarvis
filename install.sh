#!/bin/bash

# Preparation
## Copy the arch.iso to a USB drive
## dd if=/path/to/arch.iso of=/dev/sdx bs=4M && sync
## Reboot system off the USB 

# Installation
# run the following commands from the terminal
# mount -o remount,size=2G /run/archiso/cowspace
# pacman -Sy git
# git clone https://github.com/artisebrown/arch-install.git
# then launch the script


# Configuration
KEYS="uk"


## partition
TARGET="" # use lsblk to see what drives are on the system that you want to install to, e.g. sda, nvme0n1
DEVICE_TRIM="true" # If DEVICE supports TRIM
FILE_SYSTEM_TYPE="ext4" # (single)
#SWAP_SIZE="!2GiB !4GiB !8GiB" # (single, not supported in btrfs)

## network_install
WIFI_INTERFACE="wlo1"
WIFI_ESSID=""
WIFI_KEY=""
WIFI_HIDDEN=""
PING_HOSTNAME="www.mirrorservice.org"


## Pre-installation tasks
### Set the keyboard map
echo "Setting the keyboard to the UK layout"
loadkeys uk
#read -p "Press enter to continue"
echo ""

### Set the system clock
timedatectl set-ntp true

### Update the mirrorlist
#echo "Updating the mirrorlist..."
#pacman -Sy reflector
#reflector --country 'United Kingdom' --latest 10 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist # Grab list of fastest mirrors
#echo "Mirrorlist updated."
#echo ""


## Determin the drive name that Arch will be install on
## lsblk

## Partition, format and mount the drives and partitions
echo "Partitioning the drives"
DEVICE='/dev/'$TARGET
sgdisk -Z $DEVICE
echo "Creating the boot partition"
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:UEFI $DEVICE
echo "Creating the root partition"
sgdisk -n 2:0:+30G -t 2:8300 -c 2:Arch $DEVICE
echo "Creating the home partition"
sgdisk -n 3:0:0 -t 3:8300 -c 3:Home $DEVICE
echo ""


if [ "$TARGET" == "nvme0n1" ]; then
  # Partition the drives
  echo "Partitioning the drives"
  sgdisk -Z $DEVICE
  echo "Creating the boot partition"
  sgdisk -n 1:0:+512M -t 1:ef00 -c 1:UEFI $DEVICE
  echo "Creating the root partition"
  sgdisk -n 2:0:+30G -t 2:8300 -c 2:Arch $DEVICE
  echo "Creating the home partition"
  sgdisk -n 3:0:0 -t 3:8300 -c 3:Home $DEVICE
  echo ""

  # Format the partitions
  echo "Formating the boot partition"
  mkfs.fat -F32 ${DEVICE}p1
  echo "Formating the root partition"
  mkfs.ext4 ${DEVICE}p2
  echo "Formating the home partition"
  mkfs.ext4 ${DEVICE}p3
  echo ""

  # Mount the partitions
  echo "Mounting the root partition"
  mount ${DEVICE}p2 /mnt
  echo "Creating the boot folder and mounting the boot partition"
  mkdir /mnt/boot
  mount ${DEVICE}p1 /mnt/boot
  echo "Creating the homer folere and mounting the home partition"
  mkdir /mnt/home
  mount ${DEVICE}p3 /mnt/home
  echo ""
fi

if [ "$TARGET" == "sda" ]; then
  # Partition the drives
  echo "Partitioning the drives"
  sgdisk -Z $DEVICE
  echo "Creating the boot partition"
  sgdisk -n 1:0:+512M -t 1:ef00 -c 1:UEFI $DEVICE
  echo "Creating the root partition"
  sgdisk -n 2:0:+30G -t 2:8300 -c 2:Arch $DEVICE
  echo "Creating the home partition"
  sgdisk -n 3:0:0 -t 3:8300 -c 3:Home $DEVICE
  echo ""

  # Format the partitions
  echo "Formating the boot partition"
  mkfs.fat -F32 ${DEVICE}1
  echo "Formating the root partition"
  mkfs.ext4 ${DEVICE}2
  echo "Formating the home partition"
  mkfs.ext4 ${DEVICE}3
  echo ""

  # Mount the partitions
  echo "Mounting the root partition"
  mount ${DEVICE}2 /mnt
  echo "Creating the boot folder and mounting the boot partition"
  mkdir /mnt/boot
  mount ${DEVICE}1 /mnt/boot
  echo "Creating the homer folere and mounting the home partition"
  mkdir /mnt/home
  mount ${DEVICE}3 /mnt/home
  echo ""
fi
read -p "Press enter to continue"

## Install base system
echo "Intalling the base system"
pacstrap /mnt base base-devel intel-ucode
echo ""

## Create the file system table
echo "Creating the file system table"
genfstab -U /mnt >> /mnt/etc/fstab
echo ""

## Chroot into the new system abd run the chroot-install script
echo "Copying the chroot-install.sh to the root folder"
wget https://raw.githubusercontent.com/artisebrown/arch-install/master/chroot-install.sh
cp ./chroot-install.sh /mnt/chroot-install.sh
chmod +x /mnt/chroot-install.sh
echo "Chrooting into the new system"
arch-chroot /mnt /chroot-install.sh
read -p "Press enter to continue"
