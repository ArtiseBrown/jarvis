#!/bin/bash
# Stuff to do inside the chroot environment

## Set the timezone and hardware clock
echo "Setting the time zone and UTC"
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc
#read -p "Press enter to continue"
echo ""

## Set the localizations
echo "Setting the localisations to UK"
cp /etc/locale.gen /etc/locale.gen.bak
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
#read -p "Press enter to continue"
echo ""

## Set the computer's hostname and network access
echo "Setting the host name details"
echo "Hulk" > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost" > /etc/hosts
echo "1::1		localhost.localdomain	localhost" >> /etc/hosts
echo "127.0.1.1	hulk.localdomain	hulk" >> /etc/hosts
systemctl enable dhcpcd.service
#read -p "Press enter to continue"
echo ""

## Setup the boot loader and conf files
echo "Configuring the bootloaded"
bootctl --path=/boot install
echo "default arch" > /boot/loader/loader.conf
echo "timer 0" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf
#read -p "Press enter to continue"
echo ""

## determine the PARTUUID of /dev/sda1
echo "Creating the arch.conf bootloaded entry file"
DISKID=$(ls -l /dev/disk/by-partuuid | grep sda2 | awk '{print $9;}')
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd  /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$DISKID rw quiet" >> /boot/loader/entries/arch.conf
#read -p "Press enter to continue"
echo ""

## Add password for root, add user and update sudoers
echo "Setting the root password"
passwd
echo ""

#uncomment # %wheel ALL=(ALL) ALL in the /etc/sudoers file
echo "Uncommenting %wheel in sudoers file"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
echo ""

echo "Adding a non-root user"
useradd -m -G wheel,storage,power -s /usr/bin/fish artise
echo ""

echo "Adding password for non-root user"
passwd artise
echo ""

echo "Basic installation complete"

exit # to leave the chroot
