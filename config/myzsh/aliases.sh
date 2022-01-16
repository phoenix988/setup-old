#!/bin/bash



#update aliases
alias uali="bash /usr/bin/myscripts/c_aliases.sh"

#show ip
alias ipa="ifconfig | awk '/inet/ {print $2}' | head -n4"

#ls aliases
alias ls='lsd --color=auto'
alias la='lsd -a'
alias lA='lsd -A'
alias ll='lsd -l'
alias lla='lsd -la'
alias ld='lsd -l | grep ^d'
alias l='lsd'
alias l.="lsd -A | egrep '^\.'"
alias hidden="ls -A | grep -v ^[A-Z] | grep -v ^[a-z]"

#change cat to bat
alias cat='bat'
alias htop='btop'

#fix obvious typo's
alias cd..='cd ..'
alias pdw="pwd"
alias udpate='sudo pacman -Syyu'
alias upate='sudo pacman -Syyu'
alias updte='sudo pacman -Syyu'
alias updqte='sudo pacman -Syyu'
alias upqll="paru -Syu --noconfirm"

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#readable output
alias df='df -h'
alias fsp="df -h | grep -v /var"

#pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"
alias rmpacmanlock="sudo rm /var/lib/pacman/db.lck"

#free
alias free="free -mt"

#use all cores
alias uac="sh ~/.bin/main/000*"

#continue download
alias wget="wget -c"

#userlist
alias userlist="cut -d: -f1 /etc/passwd"

#merge new settings
alias merge="xrdb -merge ~/.Xresources"

# Aliases for software managment
# pacman or pm
alias pacman='sudo pacman --color auto'
alias update='sudo pacman -Syyu'
alias remove="sudo pacman -Rns"

# paru as aur helper - updates everything
alias pksyua="paru -Syu --noconfirm"
alias upall="paru -Syu --noconfirm"

#Aliases for my AUR helper
alias yay="paru"
alias aur="paru"

#ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

#grub update
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

#add new fonts
alias update-fc='sudo fc-cache -fv'


#switch between bash and zsh
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /usr/bin/fish && echo 'Now log out.'"

#quickly kill conkies
alias kc='killall conky'

#hardware info --short
alias hw="hwinfo --short"
alias temp="inxi -Fx | grep cpu"

#skip integrity check
alias paruskip='paru -S --mflags --skipinteg'

#check vulnerabilities microcode
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

#get fastest mirrors in your neighborhood
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"


#youtube-dl
alias yta-aac="youtube-dl --extract-audio --audio-format aac "
alias yta-best="youtube-dl --extract-audio --audio-format best "
alias yta-flac="youtube-dl --extract-audio --audio-format flac "
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a "
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3 "
alias yta-opus="youtube-dl --extract-audio --audio-format opus "
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis "
alias yta-wav="youtube-dl --extract-audio --audio-format wav "
alias ytv-best="youtube-dl -f bestvideo+bestaudio "
alias ytd="youtube-dl"

#Recent Installed Packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias riplong="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -3000 | nl"

#get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

#gpg
#verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
#receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

#maintenance
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias downgrada="sudo downgrade --ala-url https://bike.seedhost.eu/arcolinux/"

#systeminfo
alias probe="sudo -E hw-probe -all -upload"

#shutdown or reboot
alias ssn="sudo shutdown now"
alias sr="sudo reboot"

#shortcuts to directories
alias awem="cd /home/karl/.config/awesome/"
alias qm="cd /home/karl/.config/qtile/"
alias xm="cd /home/karl/.xmonad/"
alias xbm="cd /home/karl/.config/xmobar/"
alias omfm="cd /home/karl/.config/fish/conf.d"
alias movies="cd /mnt/autofs/movies"
alias dmove="cd ~/.dmenu"
alias backup="cd /mnt/autofs/backup"
alias backup-home="cd /mnt/autofs/backup/homefolder/karl"
alias media="cd /mnt/autofs/music/videos/"
alias cbak="cd ~/Yandex.Disk/Backups/homefolder/karl/"
alias app="cd /usr/share/applications/"
alias localapp="cd ~/.local/share/applications/"
alias script="cd ~/.scripts/activated"
alias scriptd="cd ~/.scripts/deactivated"
alias mm="cd /home/karl/.local/share/mail/karlfredin@gmail.com"
alias mbas="cd ~/.config/bash"
alias mqute="cd ~/.config/qutebrowser"
alias mconky="cd ~/.config/conky"
alias mpic="cd ~/Pictures"
alias mzsh="cd ~/.config/oh-my-zsh/"
alias mkitty="cd ~/.config/kitty/"
alias mkpop="cd ~/.scripts/learnkpop/"
alias vm="cd /media/vm"
alias yandex="cd /media/cloud_storage/Yandex.Disk/"
alias games="cd ~/Games"
alias games2="cd /mnt/autofs/games2/"
alias mwine="cd ~/wine"
alias mgit="cd ~/git-reps"
alias mdmenu="cd ~/.dmenu"
alias iso="cd ~/iso"

#checks the values of mouse/keyboards clicks
alias keycheck="xev"

#alias for sudo 
alias please="sudo"

#check the wmclass fo windows
alias wmclass="xprop WM_CLASS" 

#Nordvpn
alias vpn="nordvpn status"

#Image viewer
alias sxfa="sxiv -f *"
alias pp="sxiv /var/pictures/backgrounds/*"

#KVM 
alias virsh="virsh -c qemu:///system"

#Alias for vifm to add mor functionality
alias vifm="vifmrun"

#Clear command
alias cls="clear"

#RM aliases
alias rm="rm -i"
alias rmf="rm -f"
alias rmr="rm -r"
alias rmrf="rm -rf"

#vim for important configuration files
alias vaw="vim ~/.config/awesome/rc.lua"
alias vqt="vim ~/.config/qtile/config.py"
alias qE="vim ~/.config/qtile/config.py"
alias qe="vim ~/.config/qtile/config.py"
alias xe="vim ~/.xmonad/xmonad.hs"
alias vxe="vim ~/.xmonad/xmonad.hs"
alias omfe="vim ~/.config/fish/conf.d/omf.fish"
alias fa="vim ~/.config/fish/config.fish"
alias hostfile="sudo vim /etc/hosts"
alias ec="dm-editconfig"
alias omfA="vim ~/.config/fish/conf.d/aliases.fish"
alias vquick="vim ~/.config/qutebrowser/quickmarks"
alias vqute="vim ~/.config/qutebrowser/config.py"
alias vlightdm="sudo vim /etc/lightdm/lightdm.conf"
alias vpacman="sudo vim /etc/pacman.conf"
alias vgrub="sudo vim /etc/default/grub"
alias vconfgrub="sudo vim /boot/grub/grub.cfg"
alias vmkinitcpio="sudo vim /etc/mkinitcpio.conf"
alias vmirrorlist="sudo vim /etc/pacman.d/mirrorlist"
alias vali="vim ~/Documents/alias.list"
alias vzrc="vim ~/.zshrc"
alias vzsh="vim ~/.zshrc"
alias vfis="vim ~/.config/fish/config.fish"

#Gui editor
alias nv="neovide"

#SSH 
alias proxyserver="ssh karl@proxy"
alias dockerserver="ssh karl@10.1.0.15"
alias phoe01="ssh karl@phoe01"  
alias phoe02="ssh karl@phoe02"  
alias phoe03="ssh karl@phoe03"  
alias phoe04="ssh karl@10.1.0.20"  
alias phoe05="ssh karl@10.1.0.40"  
alias kssh="kitty +kitten ssh"

#git aliases
alias genc="git clone https://notabug.org/Krock/GI-on-Linux.git"
alias mgen="cd /media/vg_games/genshin-impact/drive_c/Program\ Files/Genshin\ Impact/Genshin\ Impact\ game"

#games legendary 
alias gta="legendary launch 9d2d0eb64d5c44529cece33fe2a46482"     

#gpg
alias dec="gpg --decrypt"

#default browser
alias defaultbrowser="xdg-settings set default-web-browser"
alias filetokrusader="xdg-mime default org.kde.krusader.desktop inode/directory application"
alias filetopcmanfm="xdg-mime default pcmanfm.desktop inode/directory application"


#Change the default xclip behaviour 
alias xclip="xclip -selection clipboard"

#Sets some Variables
export EDITOR=vim
export VISUAL=vim
export omf=/home/karl/.config/fish/conf.d/omf.fish
export awe=/home/karl/.config/awesome/rc.lua
export qt=/home/karl/.config/qtile/config.py
export github='https://github.com'


