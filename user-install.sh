#! /bin/bash

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
