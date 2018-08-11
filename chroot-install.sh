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
echo "Setting the localisations to the UK"
cp /etc/locale.gen /etc/locale.gen.bak
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
rm /etc/locale.gen
mv /etc/locale.gen.bak /etc/locale.gen
#read -p "Press enter to continue"
echo ""

## Set the computer's hostname and network access
echo "Setting the host name details"
read -p "Set a hostname: " hostnamevar
echo $hostnamevar > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost" > /etc/hosts
echo "1::1		localhost.localdomain	localhost" >> /etc/hosts
echo "127.0.1.1	$hostnamevar.localdomain	$hostnamevar" >> /etc/hosts
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

## determine the PARTUUID of /dev/sda1
echo "Creating the arch.conf bootloaded entry file"
DISKID=$(ls -l /dev/disk/by-partuuid | grep sda2 | awk '{print $9;}')
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
#echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
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
echo "Installing XFCE4"
pacman -S xfce4 xfce4-goodies --needed --noconfirm
echo ""

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
alsamixer # to check on the unmuted channels, if needed
echo ""

# uncomment # %wheel ALL=(ALL) ALL in the /etc/sudoers file
echo "Uncommenting %wheel in sudoers file"
#sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
#echo ""
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

## Add password for root 
echo "Setting the root password:"
passwd
echo ""

## Add a user
echo "Add system user"
read -p 'Username: ' usernamevar
useradd -m -G wheel,storage,power -s /usr/bin/fish $usernamevar
passwd $usernamevar
echo ""

## Get access to the AUR
#sudo su - $usernamevar -c "mkdir -p /home/$usernamevar/tmp/{package-query,yaourt}"
#sudo su - $usernamevar -c "mkdir -p /home/$usernamevar/.config/fish"
#sudo su - $usernamevar -c "echo '/user-install.sh' > /home/$usernamevar/.config/fish/config.fish"
#sudo su - $usernamevar -c "git clone https://aur.archlinux.org/package-query.git"
#sudo su - $usernamevar -c "cd /home/$usernamevar/package-query"
#sudo su - $usernamevar -c "makepkg -si"
#sudo su - $usernamevar -c "cd /home/$usernamevar"
#sudo su - $usernamevar -c "git clone https://aur.archlinux.org/yaourt.git"
#sudo su - $usernamevar -c "cd /home/$usernamevar/yaourt"
#sudo su - $usernamevar -c "makepkg -si"
#sudo su - $usernamevar -c "yaourt -Syua"

echo "Basic installation complete"

#exit # to leave the chroot
