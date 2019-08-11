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

## Users and passworda
ROOT_PASSWORD=""
USER_NAME=""
USER_NAME_PASSWORD=""

## Partition target
TARGET="" # use lsblk to see what drives are on the system that you want to install to, e.g. sda, nvme0n1
DEVICE_TRIM="true" # If DEVICE supports TRIM
FILE_SYSTEM_TYPE="ext4" # (single)
#SWAP_SIZE="!2GiB !4GiB !8GiB" # (single, not supported in btrfs)

## System details
TOUCH_PAD="" # either yes or no
LAPTOP="" # either yes or no, so config for battery status can be added


## Host name
HOST_NAME=""

## Wifi details
WIFI_INTERFACE="wlo1"
WIFI_ESSID=""
WIFI_KEY=""
WIFI_HIDDEN=""
PING_HOSTNAME="www.mirrorservice.org"


## Pre-installation tasks
### Set the keyboard map
echo "Setting the keyboard to the UK layout"
loadkeys uk
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

## Install base system
echo "Intalling the base system"
pacstrap /mnt base base-devel intel-ucode
echo ""

## Create the file system table
echo "Creating the file system table"
genfstab -U /mnt >> /mnt/etc/fstab
echo ""

## Chroot into the new system abd run the chroot-install script
#echo "Copying the chroot-install.sh to the root folder"
#wget https://raw.githubusercontent.com/artisebrown/arch-install/master/chroot-install.sh
#cp ./chroot-install.sh /mnt/chroot-install.sh
#chmod +x /mnt/chroot-install.sh
#echo "Chrooting into the new system"
#arch-chroot /mnt /chroot-install.sh
#read -p "Press enter to continue"
arch-chroot /mnt

## Set the timezone and hardware clock
echo "Setting the time zone and UTC"
#rm /etc/localtime
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc
#read -p "Press enter to continue"
echo ""

## Set the localizations
echo "Setting the localisations to the UK"
cp /etc/locale.gen /etc/locale.gen.bak
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
rm /etc/locale.gen
mv /etc/locale.gen.bak /etc/locale.gen
#read -p "Press enter to continue"
echo ""

## Set the computer's hostname and network access
echo "Setting the host name details"
#read -p "Set a hostname: " hostnamevar
echo $HOST_NAME > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost" > /etc/hosts
echo "1::1		localhost.localdomain	localhost" >> /etc/hosts
echo "127.0.1.1	$hostnamevar.localdomain	$hostnamevar" >> /etc/hosts
#systemctl enable dhcpcd.service
pacman -S networkmanager --needed --noconfirm
systemctl enable NetworkManager
#read -p "Press enter to continue"
echo ""

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


## Hook to reload the chip microcode
#mkdir /etc/pacman.d/hooks
#echo "[Trigger]" > /etc/pacman.d/hooks/microcode_reload.hook
#echo "Operation = Install" >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "Operation = Upgrade" >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "Operation = Remove" >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "Type = File" >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "Target = usr/lib/firmware/intel-ucode/*" >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "" >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "[Action]"  >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "Description = Applying CPU microcode updates..." >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "When = PostTransaction"  >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "Depends = sh"  >> /etc/pacman.d/hooks/microcode_reload.hook
#echo "Exec = /bin/sh -c 'echo 1 > /sys/devices/system/cpu/microcode/reload'" >> /etc/pacman.d/hooks/microcode_reload.hook


## determine the PARTUUID of /dev/sda1
#echo "Determining the UUID to use in the bootloader entry file"
#if ls -l /dev/disk/by-partuuid | grep nvme0n1p2 > /dev/null; then
#    echo "NVME drive found"
#    DISKID=$(ls -l /dev/disk/by-partuuid | grep nvme0n1p2 | awk '{print $9;}')
#elif ls -l /dev/disk/by-partuuid | grep sda2 > /dev/null; then
#    echo "Non-NVME drive found"
#    DISKID=$(ls -l /dev/disk/by-partuuid | grep sda2 | awk '{print $9;}')
#fi    
#read -p "Press enter to continue"

DISKID=$(ls -l /dev/disk/by-partuuid | grep nvme0n1p2 | awk '{print $9;}')


echo "Creating the arch.conf bootloader entry file"
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$DISKID rw quiet" >> /boot/loader/entries/arch.conf
#read -p "Press enter to continue"
echo ""

# System software
pacman -S fish git emacs sudo terminator xdg-user-dirs --needed --noconfirm

## Windows system
echo "Installing x windows"
pacman -S xorg-server accountsservice --needed --noconfirm
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --needed --noconfirm
echo ""

## Video driver
if lspci | grep VGA | grep VirtualBox > /dev/null; then
    pacman -S virtualbox-guest-modules-arch virtualbox-guest-utils --needed --noconfirm
fi
if lspci | grep VGA | grep Intel > /dev/null; then
    pacman -S xf86-video-intel --needed --noconfirm
fi

## XFCE4
#echo "Installing XFCE4"
#pacman -S xfce4 xfce4-goodies --needed --noconfirm
#echo ""

## i3wm
pacman -S i3-wm i3blocks i3status dmenu --needed --noconfirm
pacman -S compton feh rofi scrot python-requests --needed --noconfirm
 
## Sound system
pacman -S alsa-firmware alsa-utils alsa-plugins --needed --noconfirm
pacman -S pulseaudio-alsa pulseaudio pavucontrol pamixer pulseaudio-bluetooth --needed --noconfirm
pacman -S playerctl bluez bluez-utils --needed --noconfirm

# Software to install
## System
pacman -S gksu gparted elinks python --needed --noconfirm
pacman -S network-manager-applet python-ndg-httpsclient --needed --noconfirm

## Web browswer software
pacman -S chromium pepper-flash --needed --noconfirm
pacman -S thunar thunar-archive-plugin file-roller tumbler --needed --noconfirm

## Video
pacman -S mplayer smplayer gstreamer --needed --noconfirm

## General software
pacman -S  geany texlive-core texmaker --needed --noconfirm

## Apperance
### Themes
pacman -S arc-gtk-theme arc-icon-theme lxappearance --needed --noconfirm
### Fonts
pacman -S ttf-dejavu --needed --noconfirm

## AUR software
#yaourt -S dropbox dropbox-cli --needed --noconfirm

## YouTube downloading
pacman -S youtube-dl ffmpeg wmctrl xclip xdotool --needed --noconfirm

## Network time service
pacman -S ntp --needed --noconfirm

## Services to enable and start
echo "Enabling services"
systemctl enable NetworkManager.service
systemctl enable ntpd.service
systemctl enable lightdm.service
systemctl enable bluetooth.service

## Virtual Box
if lspci | grep VGA | grep Intel > /dev/null; then
    echo "Installing virtualbox"
    pacman -S virtualbox virtualbox-host-modules-arch --needed --noconfirm
    systemd-modules-load.service
    echo ""
fi
   
# Umnute the sound system
echo "Unmuting the sound system"
amixer sset Master unmute 
#alsamixer # to check on the unmuted channels, if needed
echo ""

# uncomment # %wheel ALL=(ALL) ALL in the /etc/sudoers file
echo "Uncommenting %wheel in sudoers file"
#sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
#echo ""
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

## Add password for root 
echo "Setting the root password:"
passwd $ROOT_PASSWORD
echo ""

## Add a user
echo "Add system user"
useradd -m -G wheel,storage,power -s /usr/bin/fish $USER_NAME
passwd $USER_NAME_PASSWORD
echo ""

read -p "Installation complete; remove installation media and press enter to reboot."
reboot
