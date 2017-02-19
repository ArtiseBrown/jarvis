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
#systemctl enable dhcpcd.service
pacman -S networkmanager --needed --noconfirm
systemctl enable NetworkManager
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

# System software
pacman -S fish git emacs sudo terminator xdg-user-dirs --needed --noconfirm

## Windows system
echo "Installing x windows"
#pacman -S xorg-server xorg-server-utils lightdm-gtk-greeter-settings accountsservice --needed --noconfirm
ehco ""

## Video driver
#if lspci | grep VGA | grep VirtualBox > /dev/null; then
#    pacman -S virtualbox-guest-modules-arch virtualbox-guest-utils --needed --noconfirm
#fi
#if lspci | grep VGA | grep Intel > /dev/null; then
#    pacman -S xf86-video-intel --needed --noconfirm
#fi

## XFCE4
ehco "Installing XFCE4"
#pacman -S xfce4 xfce4-goodies --needed --noconfirm
echo ""

## i3wm
#pacman -S i3-wm i3block i3status dmenu py3status py3status-modules --needed --noconfirm
#pacman -S compton feh rofi scrot python-requests cower yad --needed --noconfirm
 
## Sound system
#pacman -S alsa-firmware alsa-utils alsa-plugins --needed --noconfirm
#pacman -S pulseaudio-alsa pulseaudio pavucontrol pulseaudio-bluetooth --needed --noconfirm
#pacman -S pa-applet pulseaudio-ctl playerctl bluez bluez-utils --needed --noconfirm

# Software to install
## System
#pacman -S gksu gparted elinks  python --needed --noconfirm
#pacman -S gcvs --needed --noconfirm
#pacman -S network-manager-applet python-ndg-httpsclient --needed --noconfirm

## Web browswer software
#pacman -S chromium pepper-flash chromium-widevine --needed --noconfirm
#pacman -S thunar thunar-archive-plugin file-roller tumbler --needed --noconfirm

## Video
#pacman -S mplayer smplayer gstreamer --needed --noconfirm

## General software
#pacman -S  geany texlive-core texmaker --needed --noconfirm

## Apperance
### Themes
#pacman -S arc-gtk-theme arc-icon-theme lxapperance --needed --noconfirm
### Fonts
#pacman -S ttf-dejavu ttf-font-awesome --needed --noconfirm

## AUR software
#yaourt -S dropbox dropbox-cli --needed --noconfirm

## Network time service
#pacman -S ntp --needed --noconfirm

## Services to enable and start
echo "Enabling services"
#systemctl enable NetworkManager.service
#systemctl enable ntpd.service
#systemctl enable lightdm.service
#systemctl enable bluetooth.service

## Virtual Box
#if lspci | grep VGA | grep Intel > /dev/null; then
#    echo "Installing virtualbox"
#    pacman -S virtualbox virtualbox-host-modules-arch --needed --noconfirm
#    systemd-modules-load.service
#    echo ""
#fi
   
# Umnute the sound system
echo "Unmuting the sound system"
#amixer sset Master unmute 
#alsamixer # to check on the unmuted channels, if needed
echo ""

# uncomment # %wheel ALL=(ALL) ALL in the /etc/sudoers file
echo "Uncommenting %wheel in sudoers file"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
echo ""

# add user
echo "Adding Artise as a non-root user"
useradd -m -G wheel,storage,power -s /usr/bin/fish artise
echo ""

## Get access to the AUR
#sudo su - artise -c "mkdir -p /home/artise/tmp/{package-query,yaourt}"
sudo su - artise -c "mkdir -p /home/artise/.config/fish"
sudo su - artise -c "echo "/user-install.sh" > /home/artise/.config/fish/config.fish"
#sudo su - artise -c "git clone https://aur.archlinux.org/package-query.git"
#sudo su - artise -c "cd /home/artise/package-query"
#sudo su - artise -c "makepkg -si"
#sudo su - artise -c "cd /home/artise"
#sudo su - artise -c "git clone https://aur.archlinux.org/yaourt.git"
#sudo su - artise -c "cd /home/artise/yaourt"
#sudo su - artise -c "makepkg -si"
#sudo su - artise -c "yaourt -Syua"

## Add password for root 
echo "Setting the root password"
passwd
echo ""

## Add password for Artise 
echo "Adding password for Artise"
passwd artise
echo ""

echo "Basic installation complete"

#exit # to leave the chroot
