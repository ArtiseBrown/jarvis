#! /bin/bash

## Setup some symlinks
mkdir /.config
ln -s ~/Dropbox/arch-system-config/config-files/i3/ ~/.config
ln -s ~/Dropbox/arch-system-config/config-files/terminator/ ~/.config
ln -s ~/Dropbox/arch-system-config/config-files/wallpaper/ ~/.config


## Get access to the AUR
mkdir -p /home/artise/tmp/{package-query,yaourt}
cd /home/artise/tmp
git clone https://aur.archlinux.org/package-query.git
cd /home/artise/tmp/package-query
makepkg -si
cd /home/artise/tmp
git clone https://aur.archlinux.org/yaourt.git
cd /home/artise/tmp/yaourt
makepkg -si
yaourt -Syua

## Install software
yaourt -S py3status py3status-modules cower yad --needed --noconfirm
yaourt -S pa-applet-git chromium-widevine ttf-font-awesome --needed --noconfirm
yaourt -S dropbox

## Configure folders
