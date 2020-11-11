# Install KVM/QEMU
`pacman -S qemu ovmf virt-mananger ebtables dnsmasq`

## PCI passthrough (for any device, but especially for 3D graphics)

	__1. find device pci_id (....:....)__
	
	`lspci -nnk`
	
	__2. append passthrough command; to 'options' part of bootloader .conf (/boot/loader/entries/...) for systemd, or to GRUB_CMDLINE_LINUX_DEFAULT (/etc/default/grub) for GRUB then __
	
	`intel_iommu=on vfio-pci.ids=....:....[,....:....]` [INTEL]
	
	`iommu=pt vfio-pci.ids=....:....[,....:....]` [AMD]
  
  `sudo grub-mkconfig -o /boot/grub/grub.cfg` [GRUB]
	
	__3. edit QEMU config to use ovmf (/etc/libvirt/qemu.conf)__
	
	```	
nvram = [
 "/usr/share/ovmf/x64/OVMF_CODE.fd:/usr/share/ovmf/x64/OVMF_VARS.fd"
]
	```


  __4. configure the virtual machine__
  
  https://www.youtube.com/watch?v=HXgQVAl4JB4&ab_channel=RavenRepairCo.


	__5. blacklist GPU in /etc/modprobe.d/blacklist.conf__

  NVIDIA
 
  ```
blacklist nouveau
blacklist nvidia
```
  AMD
  `blacklist radeon`

Note that you'll have to remove these if you want to use your card within Linux.

