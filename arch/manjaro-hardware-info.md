## Graphics info
```
inxi -G
```
> see also other options like -A -D -m -C etc.


## MHWD

list drivers:
```
mhwd -l
```

detailed list:
```
mhwd -l -d --pci
```

install driver:
```
mhwd -i pci <driver name>
```

list installed kernels:
```
mhwd-kernel -li
```

list available kernels
```
mhwd-kernel -l
```


## INITCPIO
The ARCH way

install drivers using config files in /etc/mkinitcpio.d:
```
mkinitcpio -p linux<kernelversion>
```
