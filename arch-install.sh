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
### keyboard map
echo "Setting the keyboard to the UK layout"
loadkeys uk
read -p "Press enter to continue"
echo ""

## Determin the drive name that Arch will be install on
## lsblk

## Partition the drive that you will use
echo "Partitioning the disk"
sgdisk -Z /dev/sda
echo "Creating the boot partition"
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:UEFI /dev/sda
echo "Creating the root partition"
sgdisk -n 2:0:+20G -t 2:8300 -c 2:Arch /dev/sda
echo "Creating the home partition"
sgdisk -n 3:0:0 -t 3:8300 -c 3:Home /dev/sda
read -p "Press enter to continue"
echo ""

## Format the drives
echo "Formating the boot partition"
mkfs.fat -F32 /dev/sda1
echo "Formating the root partition"
mkfs.ext4 /dev/sda2
echo "Formating the home partition"
mkfs.ext4 /dev/sda3
read -p "Press enter to continue"
echo ""

## Mount partitions
echo "Mounting the root partition"
mount /dev/sda2 /mnt
echo "Creating the boot folder and mounting the boot partition"
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
echo "Creating the homer folere and mounting the home partition"
mkdir /mnt/home
mount /dev/sda3 /mnt/home
read -p "Press enter to continue"
echo ""

## Install base system
echo "Intalling the base system"
pacstrap /mnt base base-devel intel-ucode fish git emacs sudo
read -p "Press enter to continue"
echo ""

## Create the file system table
echo "Creating the file system table"
genfstab -U /mnt >> /mnt/etc/fstab
read -p "Press enter to continue"
echo ""

# Stuff to do inside the chroot environment
cat <<EOF > /mnt/root/tmp/part2.sh
#!/bin/bash
## Set the timezone and hardware clock
echo "Setting the time zone and UTC"
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc
read -p "Press enter to continue"
echo ""

## Set the localizations
echo "Setting the localisations to UK"
cp /etc/locale.gen /etc/locale.gen.bak
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
read -p "Press enter to continue"
echo ""

## Set the computer's hostname and network access
echo "Setting the host name details"
echo "Hulk" > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost" > /etc/hosts
echo "1::1		localhost.localdomain	localhost" >> /etc/hosts
echo "127.0.1.1	hulk.localdomain	hulk" >> /etc/hosts
systemctl enable dhcpcd.service
read -p "Press enter to continue"
echo ""

## Setup the boot loader and conf files
echo "Configuring the bootloaded"
bootctl --path=/boot install
echo "default arch" > /boot/loader/loader.conf
echo "timer 0" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf
read -p "Press enter to continue"
echo ""

## determine the PARTUUID of /dev/sda1
echo "Creating the arch.conf bootloaded entry file"
DISKID=$(ls -l /dev/disk/by-partuuid | grep sda2 | awk '{print $9;}'
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd  /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$DISKID rw quiet" >> /boot/loader/entries/arch.conf
read -p "Press enter to continue"
echo ""

## Add password for root, add user and update sudoers
echo "Setting the root password"
passwd
#read -p "Press enter to continue"
echo "Basic installation complete"
#uncomment %wheel ALL=(ALL) ALL in the /etc/sudoers file
#useradd -m -G wheel,storage,power -s /usr/bin/fish artise
#passwd artise
exit # to leave the chroot
EOF

## Chroot into the new system abd run the scripts above
echo "Chrooting into the new system"
arch-chroot /mnt /root/tmp/part2.sh
read -p "Press enter to continue"
echo ""

## Get access to the AUR
#su artise
#cd /tmp
#git clone https://aur.archlinux.org/package-query.git
#cd /tmp/package-query
#makepkg -si
#cd /tmp
#git clone https://aur.archlinux.org/yaourt.git 
#cd /tmp/yaourt
#makepkg -si
#yourt -Syua

## Add plymouth to the initial boot screen

## Setup the login manager
#yaourt -S lightdm-webkit2-greeter --noconfirm
#sudo systemctl enable lightdm.service




## Add archlinuxfr to pacman.conf
# [archlinuxfr]
# SigLevel = Never
# Server = http://repo.archlinux.fr/$arch

# Software to install
## Main system
#sudo yaourt -S gksu teminator dropbox gparted elinks bluez bluez-utils python 
#sudo yaourt -S gcvs xdg-user-dirs network-manager network-manager-applet ntp python-ndg-httpsclient

## Windows system
#sudo yaourt -S xorg-server xorg-server-utils lightdm-gtk-greeter-settings accountsservice
#sudo yaourt -S i3-wm i3blocks terminator i3status dmenu py3status py3status-modules
#sudo yaourt -S compton feh rofi scrot python-requests cower dropbox-cli yad
 
## Sound system
#sudo yaourt -S alsa-firmware alsa-utils alsa-plugins pulseaudio-alsa pulseaudio pavucontrol pulseaudio-bluetooth
#sudo yaourt -S mplayer smplayer gstreamer pa-applet pulseaudio-ctl playerctl

## General software
#sudo yaourt -S chromium pepper-flash chromium-widevine thunar thunar-archive-plugin file-roller tumbler geany texlive-core texmaker 

## Apperance
#sudo yaourt -S arc-gtk-theme arc-icon-theme lxapperance ttf-dejavu ttf-font-awesome 

## Services to enable and start
##sudo systemctl enable NetworkManager.service
#sudo systemctl enable ntpd.service
#sudo systemctl enable lightdm.service
#sudo systemctl enable bluetooth.service

## Virtual Box
#sudo yaourt -S virtualbox virtualbox-host-modules-arch
#systemd-modules-load.service
   
# Umnute the sound system
#amixer sset Master unmute 
#alsamixer # to check on the unmuted channels, if needed


# Software configurations
## i3
### ~/.i3/config
#### Software startup
#     exec --no-startup-id "pulseaudio --start
#     exec --no-startup-id nm-applet
#     exec --no-startup-id feh --bg-fill ~/Pictures/Dark-pattern.jpg
#     exec --no-startup-id dropbox start
#     exec --no-startup-id "setxkbmap -model pc105 -layout gb"
#     exec --no-startup-id pamac-tray
     
#### Multimedia keys
# Multimedia Keys
# increase volume
# bindsym XF86AudioRaiseVolume exec amixer -q set Master 5%+ unmute
# decrease volume
# bindsym XF86AudioLowerVolume exec amixer -q set Master 5%- unmute
# mute volume
# bindsym XF86AudioMute exec amixer -q set Master mute
# pause / play / next / previous
# bindsym XF86AudioPlay exec playerctl play-pause
# bindsym XF86AudioNext exec playerctl next
# bindsym XF86AudioPrev exec playerctl previous

#### Other key bindings
# bindsym $mod+d exec --no-startup-id i3-dmenu-desktop
# bindsym Print exec scrot -e 'mv $f ~/Pictures/Screenshots'

### ~/.i3status
#    order += "volume master"
#    ...
#    ...
#    ...

#    volume master {
#        format = "V: %volume"
#        device = "default"
#        mixer = "Master"
#        mixer_idx = 0
#	}
    
## Terminator
   
## Thunar
## Rofi
## Lightdm
### Add your avatar to the login screen
#    Eure the accountsservice package from the official repositories is installed
#    
#    Create a file /var/lib/AccountsService/users/myUserName
#    add the following to it:
#      [User]
#      Icon=/var/lib/AccountsService/icons/myUserName
#
#    Create the file /var/lib/AccountsService/icons/myUserName using a 
#    96x96 PNG image file.
#
#    Note: Make sure that both created files have 644 permissions, 
#    use chmod to correct them
#
#    To convert a jpg with the correct dimensions do the following:
#      sudo convert artise.jpg -resize 96x96 artise.png

# Config files to keep copies of
#  .emacs
#  .config/i3/config
#  .confif/terminatir/config
#  .config/Thunar/???

# Linking folders in my home folder
## Make a change to the $HOME/.config/user-dirs.dirs
#   Replace XDG_PICTURES_DIR="$HOME/Wallpaper"
#   Replace XDG_TEMPLATES_DIR="$HOME/GTD"

## Run the following commands:
### Remove unused folders:
# rm -rf $HOME/Desktop
# rm -rf $HOME/Documents       
# rm -rf $HOME/Downloads    
# rm -rf $HOME/Pictures
# rm -rf $HOME/Music
# rm -rf $HOME/Templates
# rm -rf $HOME/Videos

### Link to Dropbox folders:
# ln -s /home/artise/Dropbox/documents /home/artise
# ln -s /home/artise/Dropbox/Downloads /home/artise
# ln -s /home/artise/Dropbox/wallpaper /home/artise
# ln -s /home/artise/Dropbox/gtd /home/artise
# ln -s /home/artise/Dropbox/arch-system-config/_thor/i3 /home/artise/.config/i3

# Useful commands
