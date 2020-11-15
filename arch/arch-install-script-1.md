# INSTALL ARCH

v.2020.11.15


Compiled from:
 1. The official ARCH wiki 
 2. Youtube https://www.youtube.com/watch?v=a00wbjy2vns
    Wiki -> https://wiki.learnlinux.tv/index.php/How_to_Install_Arch_Linux#Copy_the_locale_file_to_locale_directory
 3. Youtube https://www.youtube.com/watch?v=RJt4i89Ofsw

___

## STAP 0: PREP
Check if you have UEFI mode enabled. If this directory exists, you have a UEFI enabled system.
`   ls /sys/firmware/efi/efivars`


___

## STAP 1: INTERNET

1. Check if you have an IP

`   ip addr show`

or

`   ip a`


2. connect to wifi

`   wifi-menu`

3. if DHCP seems to fail

`   dhcpcd`

4. test connection

`   ping www.google.com`

___

## STAP 2: KIES DOWNLOADMIRROR

1. Remove & Sort mirrors for your location

* manual

`   nano /etc/pacman.d/mirrorlist`

* automatic (replace "NL" with your country code)

```
    pacman -Syy
    pacman -S reflector
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    reflector -c "NL" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
```

2. Test de geselecteerde mirrors
`   pacman -Syyy`

___


## STAP 3: PARTITIONING

1. Show available drives

`fdisk -l`

of 

`lsblk`

2. choose disk

`fdisk /dev/<choose>`

3. show current layout __'p'__

4. create new partition table __'g'__

5. create new EFI partition  __'n'__

.... size  __'+500M'__
... type  __'t'__ then  __'1'__


6. create datapartitions  __'n'__

... size  __'...'__


7. write layout to disk  __'w'__


___


## STAP 4: FORMAT & MOUNT

* Format EFI:

`   mkfs.fat -F32 /dev/<PART0>`

* The other partitions:

`   mkfs.ext4 /dev/<PARTn>`

or

`   mkfs.btrfs /dev/<PARTn)`


* Mount root- & bootpartition

`   mount /dev/<PARTn> /mnt`

`   mount /dev/<PART0> /mnt/boot`

* Show mounts

`   df -h`

_**OPTIONAL**_

* separate home dir

`   mkdir /mnt/home`

`   mount /dev/<PARTn> /mnt/home`


___


## STAP 5: FSTAB AANMAKEN

* create _/etc_ dir

`   mkdir /mnt/etc`

* create filetable

`   genfstab -U -p /mnt >> /mnt/etc/fstab`

* check

`   cat /mnt/etc/fstab`

___


## STAP 6: DOWNLOAD ARCH BASE FILES
`   pacstrap /mnt base nano lshw htop`

___


## STAP 7: CHROOT

`   arch-chroot /mnt`

___


## STAP 8: INSTALL LINUX KERNEL & FIRMWARE

`   pacman -S linux-lts linux-lts-headers linux-firmware`

**firmware are drivers, DONT SKIP!**

___


## STAP 9: OTHER (GENERALLY REQUIRED) TOOLS
* ssh

```
   pacman -S openssh`
   systemctl enable sshd`
```

* software development

`   pacman -S base-devel`

* network tools

```
   pacman -S networkmanager wpa_supplicant wireless_tools netctl dialog`
   systemctl enable NetworkManager`
```

___

## STAP 10: CREATE RAMDISK FOR EACH KERNEL

* LTS

`   mkinitcpio -p linux-lts`

* Other

`   mkinitcpio -p linux`

___

## STAP 11: LOCALE & TIMEZONE

* Uncomment your language:

`   nano /etc/locale.gen`

* Apply these changes:

`   locale-gen`

* Also here:

`   nano /etc/locale.conf`

> LANG=nl_NL.UTF-8

* Timezone:

`   timedatectl set-ntp true`

`   timedatectl list-timezones` (optional)

`   timedatectl set-timezone Europe/Amsterdam`  (set yours)


To check the service status, use

`   timedatectl status`


___

## STAP 12: HOSTNAME & HOSTS

`   nano /etc/hostname`

>  your-hostname

`   nano /etc/hosts`

>  127.0.0.1	localhost

>  ::1		localhost

>  127.0.1.1	_pcnaam_


___

## STAP 13: PASSWORD EN USER

voor root

`   passwd`

extra users ('wheel' is the sudo-group)
```
   useradd -m -g users -G wheel USERNAME`
   passwd USERNAME`
```

___

## STAP 14: SUDO
check install

`   pacman -S sudo`


edit sudo-file (using special commando)

`   EDITOR=nano visudo`

(uncomment line with %wheel ALL ALL)


___

## STAP 15A: SYSTEMD-BOOT

1. Install

`   bootctl install`

2. Configure /boot/loader/loader.conf

3. Add /boot/loader/entries/*.conf

4. Check

`   bootctl status`
___

## STAP 15B: GRUB

1. download

`   pacman -S grub efibootmgr dosfstools os-prober mtools`

2. mount EFI partition

`   mkdir /boot/EFI`

`   mount /dev/PART0 /boot/EFI`

3. install
```
   grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck`
   grub-mkconfig  -o /boot/grub/grub.cfg`
```

___

## STAP 16: SWAPFILE
 * ONLY for copy-on-write file systems like Btrfs, first:
```
    truncate -s 0 /swapfile
    chattr +C /swapfile
    btrfs property set /swapfile compression none
```

1. Create swap-file
```
   fallocate -l 4G /swapfile`
   chmod 600 /swapfile`
   mkswap /swapfile`
```

2. Mount at startup
```
   cp /etc/fstab /etc/fstab.bak`
   nano /etc/fstab`
```

> /swapfile none swap sw 0 0


___

## STAP 17: FINALIZE & REBOOT

cpu microcode

`   pacman -S intel-ucode/amd-ucode` (select which one is appropriate)

Exit the chroot environment

`   exit`

Unmount everything (some errors are okay here)

`   umount -a`

Reboot the machine

`   reboot`

__(to reconnect to wifi after reboot run `ntmui`)__


___

## STAP 18: GRAPHICAL DESKTOP ENVIRONMENTS

### XORG

1. update
`   pacman -Syyu`

2. xorg
`   pacman -S xorg xorg-server`

3. drivers

* AMD

`   pacman -S xf86-video-amdgpu mesa lib32-mesa`

* INTEL

`   pacman -S xf86-video-intel mesa lib32-mesa`

* NVIDIA

(open-source)

`   pacman -S xf86-video-nouveau mesa lib32-mesa`

(proprietary)

`   pacman -S nvidia-lts nvidia-utils`


* for Virtualbox
`   pacman -S virtualbox-guest-utils xf86-video-vmware`

4. OpenCL

* AMD

`   pacman -S clinfo ocl-icd opencl-mesa`

* NVIDIA

`   pacman -S clinfo ocl-icd opencl-nvidia`

* Intel

Broadwell+
`   pacman -S clinfo ocl-icd intel-compute-runtime`

Legacy
`   pacman -S clinfo ocl-icd intel-opencl-runtime`


* ALL: force ocl-icd loader

`   echo "/usr/lib" > /etc/ld.so.conf.d/00-usrlib.conf`


### DM & DE

#### gnome

```
    pacman -S gnome gnome gnome-extra gdm
    systemctl enable gdm.service
```

__options:__

`gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true`

> GNOME has good online-account integration with google-contacts, google-calendar, geary & nautilus

> Enable location services under 'Privacy' to enable network-time, location and weather

> Good audio extension: __Sound Input & Output Device Chooser by kgshank__


#### plasma

```
    pacman -S plasma sddm kde-applications
    systemctl enable sddm.service
```

__(Set NumLock in SDDM config)__


#### xfce*
```
    pacman -S xfce4 xfce4-goodies lightdm
    systemctl enable lightdm.service
```

#### lxde*
```
    pacman -S lxde lxdm
    systemctl enable lxdm.service
```

__* it should be noted that these DE's also work with the GDM or SDDS display manager__


### GTK2/QT5 theme integration

* METHOD 1: qt5platformtheme (AUR)

`    pacman -S qt5-gtk2-platformtheme`

add to _/etc/profile_

> export QT_QPA_PLATFORMTHEME=gtk2

* METHOD 2: qt5ct (AUR)

`    pacman -S qt5ct`

add to _/etc/profile_

> export QT_QPA_PLATFORMTHEME=qt5ct

..then run qt5 config tool

* METHOD 3: qgnomeplatform

> DOESNT SEEM TO WORK CONSISTENLY


___


## STAP 19: HOME FOLDERS
(Necessary if you want the 'Images' 'Downloads' 'Documents' etc. folders)

`   sudo pacman -S xdg-user-dirs`

`   xdg-user-dirs-update`

___
___


## MISC. 1: PERIPHERALS

### PRINTERS
* CUPS en PPD drivers installeren en starten:
```
    sudo pacman -S cups cups-pdf foomatic-db-ppds foomatic-db-nonfree-ppds system-config-printer (hplip)
    sudo systemctl enable org.cups.cupsd
```

* Network DNS resolving (o.a. voor netwerkprinters):
`    sudo pacman -S avahi nss-mdns`

* ...edit _/etc/nsswitch.conf_ en voeg "mdns_minimal [NOTFOUND=return]" in voor "resolve and dns":
`   hosts: ... __mdns_minimal [NOTFOUND=return]__ resolve [!UNAVAIL=return] dns ...`

* ...start service:
`   sudo systemctl enable avahi-daemon`


### BLUETOOTH
```
    pacman -S bluez bluez-utils pulseaudio-module-bluetooth
    systemctl enable --now bluetooth
```

Gnome: `    pacman -S gnome-bluetooth indicator-bluetooth`

KDE:  `    pacman -S bluedevil`


Even though KDE and Gnome have their own implementation of bluetooth, they seem to work like crap. If you cant succeed with the standard tools use blueman:

`    pacman -S blueman`



___

## MISC. 2: MULTIMEDIA / TOOLS

* multimedia

`   sudo pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gstreamer0.10-plugins mediainfo-gui`


* AUDIO functionality (not allways necessary, but doesn't hurt)
`    pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-jack pulseaudio-lirc pulseaudio-zeroconf`


* archivers

`   sudo pacman -S zip unzip p7zip p7zip unrar tar rsync ntfs-3g exfat-utils wget curl zsh`

___

## MISC. 3: AUR / STORES

### AUR (YAY)

Necessary for lots of software like _Google Chrome, Spotify, Google Earth, Zoom, Skype etc_

```
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
```

### PAMAC software store

* PAMAC (Manjaro software store)

`   yay -S pamac`

__recommended to remove other default stores like gnome-software, kde-discover etc__


* KDE Discover (to enable access to Arch & AUR repo's)

`   sudo pacman -S packagekit-qt5`

* Gnome software (to enable access to Arch, (not AUR) repo's)

`   sudo pacman -S gnome-software-packagekit-plugin`


___

## MISC. 4: EXTRAS

### FISH shell

1. install

`pacman -S fish`

2. Add '/usr/bin/fish' to _/etc/shells_ (if not exists)


3. Change standard shell:

`chsh -s /usr/bin/fish`


### Get rid of the annoying NetworkManager-wait-online message at start and shutdown

` sudo systemctl disable NetworkManager-wait-online.service` 


### Software recommendations
* qmplay2 _(excellent audio/video player with eq. & spectrum)_
* redshift-gtk/plasma-applet-redshift-control (AUR)


### Wine

1. Enable **multilib** in de repo's in _/etc/pacman.conf_

>   [multilib]

>   Include = /etc/pacman.d/mirrorlist

... then apply:

`    pacman -Syyu`


2. Install Wine

`    sudo pacman -S wine`

3. Install lib32 dependencies _(necessary to run MANY Windows applications)

See https://wiki.archlinux.org/index.php/Wine for more info

* _'Graphics drivers'_

see step 18

* _'Sound'_

`    sudo pacman -S lib32-alsa-lib lib32-alsa-plugins lib32-libpulse lib32-alsa-oss lib32-openal`

* _'Other dependencies'_

`    sudo pacman -S lib32-mpg123 lib32-giflib lib32-libpng lib32-gnutls lib32-gst-plugins-base lib32-gst-plugins-good`

__(lib32-gst-plugins-bad lib32-gst-plugins-ugly in AUR)

* _'Optional'_

`    sudo pacman -S lib32-libmpcdec lib32-libmpeg2 lib32-libldap`


___
___



## Important config files
### /etc/rc.conf
Main config file voor Arch Linux. Set keyboard, timezone, hostname, network, startup daemons, loadeing/blacklisting kernel modules etc.

### /etc/fstab
Config mounts at boottime.


### /etc/mkinitcpio.conf
Config for the ramdisk.

### /etc/modprobe.d/modprobe.conf
Config kernel modules.


### /etc/resolv.conf
Config nameservers.


### /etc/hosts
Associate computer hostnames with IP-adresses.


### /etc/hosts.deny
Config network services.
 ALL: ALL: DENY


### /etc/hosts.allow
Config network services.


### /etc/locale.gen
Config language and character sets.

### /etc/pacman.d/mirrorlist
Config your preferred Arch repo-mirrors.
