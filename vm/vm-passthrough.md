# VIRT-MANAGER met PASSTHROUGH

> bron: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF

## Installeer VM-software

``
sudo pamac install qemu libvirt edk2-ovmf virt-manager iptables-nft dnsmasq
``


``
sudo systemctl enable --now libvirtd virtlogd
``


``
sudo virsh net-autostart default
sudo virsh net-start default
``

## Configureer qemu om als root te draaien

> dit voorkomt 'storage file access' problemen

``
sudo nano /etc/libvirt/qemu.conf
``

stel *user* en *group* in als root (uncomment)

> restart libvirtd service

``
sudo systemctl restart libvirtd
``

## PASSTRHOUGH

Identificeer apparaten
``
lspci -nn | grep VGA
``

> The following script should allow you to see how your various PCI devices are mapped to IOMMU groups. If it does not return anything, you either have not enabled IOMMU support properly or your hardware does not support it.

``
#!/bin/bash
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
``
> Configureer de vfio 'fake' driver

options vfio-pci ids=[device:id1],[device:id2]

``
sudo nano /etc/modprobe.d/vfio.conf
``

> Stel modprobe in om de vfio driver te gebruiken

MODULES="... vfio_pci vfio vfio_iommu_type1 vfio_virqfd ..."

HOOKS="... modconf ..."

``
sudo nano /etc/mkinitcpio.conf
``

...en maak een nieuwe bootimage aan (in dit geval voor configuratie linux515)

``
sudo mkinitcpio -p linux515
``

Reboot & controleer of de virtio (fake) driver goed is toegewezen aan de gekozen apparaten

``
lspci -nnk -d [device:id]
``

## QEMU configuratie aanpassen

> BIOS > UEFI

> CPU > passthrough-host + socket/cores aanpassen




## Installeer het Guest-OS

1. zoals aanbevolen, eerst zonder de PCI-passthrough

2. als de installatie + virtio-drivers + updates gedaan zijn, dan de PCI apparaten toewijzen + drivers installeren


---
