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

## Pre-installation tasks
### Set the keyboard map
echo "Setting the keyboard to the UK layout..."
loadkeys uk
echo ""

### Set the system clock
echo "Setting network time..."
timedatectl set-ntp true
echo ""

### Update the mirrorlist
echo "Updating the mirrorlist..."
pacman -Sy reflector
reflector --country 'United Kingdom' --latest 10 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist # Grab list of fastest mirrors
echo "Mirrorlist updated."
echo ""


## Partition the drive that you will use
echo "Partitioning the disk..."
sgdisk -Z /dev/sda
#sgdisk -Z /dev/nvme0n1
echo "Creating the boot partition..."
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:UEFI /dev/sda
#sgdisk -n 1:0:+512M -t 1:ef00 -c 1:UEFI /dev/nvme0n1
echo "Creating the root partition..."
sgdisk -n 2:0:+30G -t 2:8300 -c 2:Arch /dev/sda
#sgdisk -n 2:0:+30G -t 2:8300 -c 2:Arch /dev/nvme0n1
echo "Creating the home partition..."
sgdisk -n 3:0:0 -t 3:8300 -c 3:Home /dev/sda
#sgdisk -n 3:0:0 -t 3:8300 -c 3:Home /dev/nvme0n1
echo ""

## Format the partitions
echo "Formating the boot partition..."
mkfs.fat -F32 /dev/sda1
#mkfs.fat -F32 /dev/nvme0n1p1
echo "Formating the root partition..."
mkfs.ext4 /dev/sda2
#mkfs.ext4 /dev/nvme0n1p2
echo "Formating the home partition..."
mkfs.ext4 /dev/sda3
#mkfs.ext4 /dev/nvme0n1p3
echo ""

## Mount partitions
echo "Mounting the root partition..."
mount /dev/sda2 /mnt
#mount /dev/nvme0n1p2 /mnt
echo "Creating the boot folder and mounting the boot partition..."
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
#mount /dev/nvme0n1p1 /mnt/boot
echo "Creating the homer folere and mounting the home partition..."
mkdir /mnt/home
mount /dev/sda3 /mnt/home
#mount /dev/nvme0n1p3 /mnt/home
echo ""

## Install base system
echo "Intalling the base system..."
pacstrap /mnt base base-devel intel-ucode linux linux-headers linux-lts linux-lts-headers linux-firmware grub efibootmgr ntp networkmanager python docker nano
echo ""

## Create the file system table
echo "Creating the file system table..."
genfstab -U /mnt >> /mnt/etc/fstab
echo ""

## Chroot into the new system abd run the chroot-install script
arch-chroot /mnt
echo ""

## Set the timezone and hardware clock
echo "Setting the time zone and UTC..."
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc
echo ""


## Set the localizations
echo "Setting the localisations to the UK..."
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
echo ""


## Set the computer's hostname and network access
echo "Setting the host name details..."
read -p "Set a hostname: " hostnamevar
echo $hostnamevar > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost" > /etc/hosts
echo "1::1		localhost.localdomain	localhost" >> /etc/hosts
echo "127.0.1.1	$hostnamevar.localdomain	$hostnamevar" >> /etc/hosts
echo ""


## Configure initramfs
echo "Configuring initramfs..."
mkinitcpio -P
echo ""


## Services to enable and start
echo "Enabling services..."
systemctl enable NetworkManager.service
systemctl enable ntpd.service
echo ""

## Set password for root 
echo "Setting the root password:"
passwd
echo ""


## Add a user
echo "Add system user:"
read -p 'Username: ' usernamevar
useradd -m -G wheel,storage,power -s /usr/bin/fish $usernamevar
passwd $usernamevar
echo ""


# uncomment # %wheel ALL=(ALL) ALL in the /etc/sudoers file
echo "Uncommenting %wheel in sudoers file"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
echo ""
#echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel



## Setup the boot loader and conf files
echo "Configuring the bootloader"
bootctl --path=/boot install
echo "default arch" > /boot/loader/loader.conf
echo "timeout 0" >> /boot/loader/loader.conf
echo "editor no" >> /boot/loader/loader.conf
#read -p "Press enter to continue"
echo ""

## Add hooks to update systemd-boot
mkdir /etc/pacman.d/hooks
echo "[Trigger]" > /etc/pacman.d/hooks/systemd-boot.hook
echo "Type = Package" >> /etc/pacman.d/hooks/systemd-boot.hook
echo "Operation = Upgrade" >> /etc/pacman.d/hooks/systemd-boot.hook
echo "Target = systemd" >> /etc/pacman.d/hooks/systemd-boot.hook
echo "" >> /etc/pacman.d/hooks/systemd-boot.hook
echo "[Action]" >> /etc/pacman.d/hooks/systemd-boot.hook
echo "Description = Upgrading systemd-boot..." >> /etc/pacman.d/hooks/systemd-boot.hook
echo "When = PostTransaction" >> /etc/pacman.d/hooks/systemd-boot.hook
echo "Exec = /usr/bin/bootctl update" >> /etc/pacman.d/hooks/systemd-boot.hook









