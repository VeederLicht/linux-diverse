## BASHRC
file: /home/.bashrc

    # COLORFULL PROMPT
    PS1="\n\n\n\`if [[ \$? = "0" ]]; then echo "\\[\\033[42m\\]"; else echo "\\[\\033[101m\\]"; fi\`\!\e[95m\e[45m  \$(/bin/date)   ---   [\u@\h] \e[0m\e[35m\e[105m\$(git branch 2>/dev/null | grep '^*' | colrm 1 2)\e[49m\e[35m\n  Current Path: \[\033[93m\]\w/\n\[\033[1;33m\]  ⇒  \[\033[0m\]"
    # SYSINFO
    neofetch


## KEYPAD

See current options:

    setxkbmap -query
    
Set comma (for european models):

    setxkbmap -option kpdl:comma
    
    

## THEMING

### QT/GTK

> Option 1

*  file: /etc/profile

        export QT_QPA_PLATFORMTHEME=gtk2

> Option 2

* Install Qt5 Configuration Utility

* file: /etc/profile

        export QT_QPA_PLATFORMTHEME=qt5ct
