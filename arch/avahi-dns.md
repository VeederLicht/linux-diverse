## INSTALLING AVAHI and NSS-MDNS

Installing these services can prevent all sorts of headeaches with *network services* like CUPS ('cups-internal-server-error') and enables *network shares* scanning in the filemanagers (see: https://github.com/OpenPrinting/cups-filters/issues/308)

    yay -S avahi nss-mdns
    
Then, edit the file /etc/nsswitch.conf and change the hosts line to include mdns_minimal [NOTFOUND=return] before resolve and dns:

    sudo nano /etc/nsswitch.conf
    
Start and enable the Avahi service:

    sudo systemctl enable --now avahi-dnsconfd.service
    
    sudo systemctl restart avahi-daemon.service
    
Check service workings:

    avahi-browse --all --ignore-local --resolve --terminate


> (Be sure to open **UDP** port **5353** if you are using a firewall)
