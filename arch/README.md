## install-arch-linux
Unofficial, non-approved, use-at-your-own-risk install manual for Arch Linux.

Contains my collection of scavenged recommendations plus some personal notes. Has allready worked lots of times for me.
(Might contain some Dutch comments)

### First time steps after fresh install:

#### Update and install domain resolver
```
yay -Syyu
yay -s avahi nss-mdns 
sudo nano /etc/nsswitch.conf
avahi-browse --all --ignore-local --resolve --terminate
sudo systemctl enable --now avahi-dnsconfd.service 
sudo systemctl enable --now avahi-daemon
```

#### Solve possible smb problems + enable ability to share folders
```
yay -S smbclient samba kio-fuse kdenetwork-filesharing gvfs-smb
sudo systemctl enable --now smb
sudo systemctl enable --now winbind.service
```

#### Install often used apps
```
yay -S zoom neofetch gdu lsd speedtest-cli kdenetwork-filesharing nomacs audacity mediainfo-gui jhead ffmpegthumbs ufraw-thumbnailer tumbler webp-thumbnailer google-chrome mpv huiontablet krita gdu btop whowatch clipgrab obs-studio retext darktable glances
```

#### Change default apps
CHECK:
```
cat /usr/share/applications/default.list
cat ~/.local/share/applications/mimeapps.list
xdg-mime --manual
xdg-mime query default application/pdf
```
TIP: use [**xdgmime-changeall.sh**](https://github.com/RickOrchard/linux-diverse/blob/master/config/xdgmime-changeall.sh) script for mass changes

#### OPTIONAL:
```
kdenetwork-filesharing brother-mfc-j5330dw powerstat powertop brscan4 nvidia-inst stacer
```

#### KDE Dolphin problem solving
Dolphin: The file or folder smb://sharename does not exist [link](https://forum.manjaro.org/t/dolphin-the-file-or-folder-smb-sharename-does-not-exist/114900)
>  In System Settings–>Network Settings–>Windows Shares, add ANY text to the user and password fields and restart Dolphin. Now I get a password prompt and can view and mount shares. 
