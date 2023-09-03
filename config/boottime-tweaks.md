# LINUX CONFIG TIPS

## 1. BASHRC
file: /home/.bashrc

```
alias list="ls -g --group-directories-first --sort=time --human-readable"
# COLORFULL PROMPT
PS1="\n\n\n\`if [[ \$? = "0" ]]; then echo "\\[\\033[42m\\]"; else echo "\\[\\033[101m\\]"; fi\`\!\e[95m\e[45m  \$(/bin/date)   ---   [\u@\h] \e[0m\e[35m\e[105m\$(git branch 2>/dev/null | grep '^*' | colrm 1 2)\e[49m\e[35m\n  Current Path: \[\033[93m\]\w/\n\[\033[1;33m\]  ⇒  \[\033[0m\]"
# SYSINFO
neofetch
```

## 2. NANORC
> maak .nanorc aan in ~ met de volgende inhoud:
```
# add this file to the ~ directory
# check the path of the local *.nanorc files

#	Ctrl+A, Ctrl+E	Move cursor to start and end of the line
#	Ctrl+Y/Ctrl+V	Move page up and down
#	Ctrl+_	Move cursor to a certain location
#	Alt+A and then use arrow key	Set a marker and select text
#	Alt+6	Copy the selected text
#	Ctrl+K	Cut the selected text
#	Ctrl+U	Paste the selected text
#	Ctrl+6	Cancel the selection
#	Ctrl+K	Cut/delete entire line
#	Alt+U	Undo last action
#	Alt+E	Redo last action
#	Ctrl+W, Alt+W	Search for text, move to next match
#	Ctrl+\	Search and replace
#	Ctrl+O	Save the modification
#	Ctrl+X	Exit the editor


include "/usr/share/nano/*.nanorc" # Enables the syntax highlighting.
#set speller "aspell -x -c"         # Sets what spelling utility to use.
set constantshow    # Displays useful information e.g. line number and position in the bottom bar.
set linenumbers     # Lines are numbered.
#set casesensitive   # Case insensitive search.
#set historylog      # Save the last 100 history searches for later use.
set positionlog     # Saves the cursor position between editing sessions.
set zap             # Allows you to highlight text (CTRL+SHIFT+ARROW) and delete it with backspace.
set autoindent      # A new line will have the same number of leading spaces as the previous one.
set indicator       # Displays a scroll bar on the right that shows the position and size of the current view port.
set minibar         # Displays file name and other information in the bottom bar. Removes top bar.
#set cutfromcursor   # CTRL+K cuts from cursor position to end of line.
#set nohelp          # Disable the help information (CTRL+G to view the help screen).
set softwrap        # Enable softwrap of lines.
set atblanks        # wrap line at blanks.
set suspend         # Enables CTRL+Z to suspend nano.
#set tabstospaces    # Converts TAB key press to spaces.
#set tabsize 4       # Sets tab-to-spaces size to 4.
set mouse
#set backup                              # Creates backups of your current file.
#set backupdir "~/.cache/nano/backups/"  # The location of the backups.
```


## 3. CLEANUP
### THUMBNAILS

    rm -R ~/.cache/thumbnails/



## 4. KEYBOARD / LANGUAGE
### KEYPAD

See current options:

    setxkbmap -query
    
Set comma (for european models):

    setxkbmap -option kpdl:comma
    
## 5. THEMING

### GTK3
> theme: Breeze-Noir-Dark-GTK
> icons: Oxylite of Nova7
> fonts:  FreeSans 11 / Victor Mono 10


### ICON CACHE
`sudo update-icon-caches /usr/share/icons/*`

#### QT5 in GTK

> Option 1 (needs qt5-styleplugins)

* file: ~/profile (local)

        export QT_QPA_PLATFORMTHEME=gtk2
        
* file: /etc/environment (global)

        QT_QPA_PLATFORMTHEME=gtk2

> Option 2

* Install Qt5 Configuration Utility

* file: ~/profile (local)

        export QT_QPA_PLATFORMTHEME=qt5ct
        
* file: /etc/environment (global)

      export QT_QPA_PLATFORMTHEME=qt5ct


## APPENDIX: ARCH / MANJARO

> MAKEPKG duurt te lang om telkens te comprimeren » uitschakelen in /etc/makepkg.conf:
```
#PKGEXT='.pkg.tar.xz'
PKGEXT='.pkg.tar'
#PKGEXT='.pkg.tar.gz'
SRCEXT='.src.tar.gz'
```

> Programma's duren te lang om op te starten:
```
sudo pacman -Rdd xdg-desktop-portal-gnome
sudo pacman -S xdg-desktop-portal-gtk
```
