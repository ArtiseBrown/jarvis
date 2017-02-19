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
