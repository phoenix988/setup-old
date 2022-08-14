#!/bin/bash
   
        
echo "################################################################"
echo "## Syncing the repos and installing 'dialog' if not installed ##"
echo "################################################################"

error() { \
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}

if [ -e /etc/pacman.conf ] ; then 
  
  sudo pacman --noconfirm --needed -Syy dialog || error "Error syncing the repos."

fi

if [ -d /etc/dnf ] ; then

  sudo dnf install -y dialog || error "Error syncing the repos."

fi

if [ -d /etc/apt ] ; then 

  sudo apt install -y dialog || error "Error syncing the repos."

fi
      
welcome() { \
    dialog --colors --title "\Z7\ZbConfigure your Desktop!" --msgbox "\Z4This is a script that will install everythinging I personally use on a daily basis, This script will run using your Normal User account but sometimes it will need root privleges so then its gonna prompt you for a password to make sure to be near your computer. Me personally tho deactivate sudo password prompts but that comes with a security risk hehe. And also if you run this script when you are installing arch linux then it will install everything you need to get started with a base install. But you will need to run this script again when you have installed the base installation of arch \\n\\n-Karl" 16 60
    }

partitionerror() { \
    dialog --colors --title "\Z7\ZbError!" --msgbox "\Z4The partition doesn't exist please write a valid one" 16 60
    }
errormsg() { \
    dialog --colors --title "\Z7\ZbError!" --msgbox "\Z4Invalid Value" 16 60
    }
Lastchance() { \
        dialog --colors --title "\Z7\ZbPoint of no Return" --yes-label "Yes Continue with the install" --no-label "No" --yesno "\Z4Up to this point No changes Have been Made. But now the installation will begin if you click yes there will be no going back. Are you sure you want to do this?" 8 60 && use_default=y 
    }




     welcome || error "user choose to exist"

     os=$(cat /etc/os-release | awk -F = '/^NAME/ {print $2}' | sed 's/"//g' | awk '{print $1}') 
     hostname=$(cat /etc/hostname)
     availabledisks=$(sudo fdisk -l | grep ^/dev | awk '{print $1}')
     availablebiosdisk=$(sudo fdisk -l | grep ^/dev | awk '{print $1}' | sed 's/[1-9]*//g')

if [ "$hostname" = "archiso" ] ; then 


fs() { \
   fs=$(dialog --colors --title "\Z7\ZbFilesystem" --inputbox "\Z4Choose your filesystem btrfs and ext4 supported?" --output-fd 1 8 60  ) 
 }
user() { \
   user=$(dialog --colors --title "\Z7\ZbUsername" --inputbox "\Z4What name do you want on your user?" --output-fd 1 8 60  ) 
 }
host_name() { \
   host_name=$(dialog --colors --title "\Z7\ZbHostname" --inputbox "\Z4Choose your hostname" --output-fd 1 8 60  ) 
 }
driveinstall() { \
  drive=$(dialog --colors --title "\Z7\ZbDiskdrive" --inputbox "\Z4What partition do you want to use for the Install?                                                             These disks are available:$availabledisks" --output-fd 1 8 60  ) 
 }
uefiorbios() { \
   bios_version=$(dialog --colors --title "\Z7\ZbBios or UEFI" --inputbox "\Z4Do you want UEFI or BIOS Install" --output-fd 1 8 60  ) 
 }
bios() { \
   biosdrive=$(dialog --colors --title "\Z7\ZbBIOS or UEFI" --inputbox "\Z4Choose Bios Drive. These disks are available:$availablebiosdisk" --output-fd 1 8 60  ) 
 }
uefi() { \
   efidrive=$(dialog --colors --title "\Z7\ZbUEFI" --inputbox "\Z4Choose EFI partition.  These disks are available:$availabledisks" --output-fd 1 8 60  ) 
 }

      
clear

[ -e $(pwd)/arch-chroot.sh ] || wget https://raw.githubusercontent.com/phoenix988/setup/main/arch-chroot.sh &> /dev/null

until [ "$fs" = "ext4" -o "$fs" = "btrfs"  ] ;
do

    fs
    
    if [ "$fs" = "ext4" -o "$fs" = "btrfs" ] ; then 

         echo "" > /dev/null 

       else

         errormsg 
    fi


done



while [ -z $user ] ; 

do
    
    user     

done

while [ -z $host_name ] ;

do
    
   host_name

done
 

until [ "$bios_version" = "u" -o "$bios_version" = "U" -o "$bios_version" = "B" -o "$bios_version" = "b" ] ; 
              
do
                 
     uefiorbios 
               
if [ $bios_version = "u" -o $bios_version = "U" -o $bios_version = "B" -o $bios_version = "b" ] ; then
               
     printf "\n"

else
     
     errormsg
 
fi 

done


while [ -z "$check_drive" ] ; do 

      driveinstall
      check_drive=$(lsblk $drive 2> /dev/null)
      check_drive=$(echo "$drive" | grep "[1-9]" )
      
      if [ -z "$check_drive" ] ; then
      
         partitionerror 
      
      else
       
         check_fstype=$(lsblk -f $drive | head -n2 | tail -n1 | awk '{print $2}' ) 
         
      
      fi

done


if [ "$bios_version" = "u" -o "$bios_version" = "U" ] ; then
   
          while [ -z "$check_efidrive" ] ; do 
       
              uefi
              
              check_efidrive=$(lsblk $efidrive 2> /dev/null)
              check_efidrive=$(echo "$efidrive" | grep "[1-9]")
             
          if [ -z "$check_efidrive" ] ; then
       
              partitionerror
          
          else
           
              echo "" &> /dev/null
       
          fi
       
          done
       
else
       
          while [ -z "$check_biosdrive" ] ; do 
       
              bios 
              
              check_biosdrive=$(lsblk $biosdrive 2> /dev/null)
              biosdrive=$(echo "$biosdrive" | sed 's/[1-9]*//g') 
          
          if [ -z "$check_biosdrive" ] ; then
       
              partitionerror
       
          else
           
              echo "" &> /dev/null
       
          fi
       
          done



fi

Lastchance || error "User choose to exit"
clear
      
echo "##########################"
echo "## Creating file system ##"
echo "##########################"
              

mkfs -t $fs -f $drive || error "Failed to create filesystem"
               
if [ $check_fstype = "btrfs" ] ; then
    
    sudo mount $drive /mnt &> /dev/null   
    sudo btrfs subvolume create /mnt/@ &> /dev/null
    sudo btrfs subvolume create /mnt/@home &> /dev/null
    sudo umount /mnt &> /dev/null
    sudo mount -o subvol=@ $drive /mnt &> /dev/null

else 

   sudo mount $drive /mnt 

fi

if [ "$bios_version" = "U"  -o "$bios_version" = "u" ] ; then

     efifstype=$(lsblk -f $efidrive | awk '{print $2}' | grep -vi fstype) 
     [ "$efifstype" = "vfat" ] || mkfs -t vfat $efidrive

fi 

echo "#####################################################"
echo "## Installing archlinux-keyring and wget if needed ##"
echo "#####################################################"
pacman -S --noconfirm --needed wget archlinux-keyring  

clear

echo "#######################################################"
echo "## Running pacstrap to install the base of archlinux ##"
echo "#######################################################"
sleep 2
pacstrap /mnt base-devel \
grub btrfs-progs networkmanager \
systemd efibootmgr linux linux-firmware \
arch-install-scripts systemd-sysvcompat git || error "Pacstrap Failed to install everything"
sleep 2
clear
[ "$check_fstype" = "btrfs" ] && sudo mount -o subvol=@home $drive /mnt/home

echo "######################"
echo "## Generating fstab ##"
echo "######################"
genfstab -U /mnt >> /mnt/etc/fstab
sleep 2
clear

chmod 775 $HOME/arch-chroot.sh
cp $HOME/arch-chroot.sh /mnt/root/ 

#Runs everything in chroot mode to configure the rest
arch-chroot /mnt echo "user=$user" >> /mnt/root/.bashrc 
arch-chroot /mnt echo "host_name=$host_name" >> /mnt/root/.bashrc 
arch-chroot /mnt echo "bios_version=$bios_version" >> /mnt/root/.bashrc 
arch-chroot /mnt echo "efidrive=$efidrive" >> /mnt/root/.bashrc 
arch-chroot /mnt echo "biosdrive=$biosdrive" >> /mnt/root/.bashrc 
arch-chroot /mnt sh $HOME/arch-chroot.sh

echo "####################"              
echo "## Chroot is done ##"
echo "####################"              

clear 
exit
else
 
    


 if [ "$(id -u)" = 0  ]; then
echo "##################################################################"
echo "This script MUST NOT be run as root user since it makes changes"
echo "to the \$HOME directory of the \$USER executing this script."
echo "The \$HOME directory of the root user is, of course, '/root'."
echo "We don't want to mess around in there. So run this script as a"
echo "normal user. You will be asked for a sudo password when necessary."
echo "##################################################################"
exit 1
 fi




defaultsettings() { \
        dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to use Default Settings?" 8 60 && use_default=y 
    }


installdocker() { \
        dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to Install Docker?" 8 60 && install_docker=y 
    }

installportainer() { \
        dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to configure a portainer agent?" 8 60 && install_portainer=y 
    }

installfonts() { \
   dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to Move all my fonts to /usr/share/fonts? (Note this can cause some problems)" 8 60 && install_fonts=y 
    }

installxorg() { \
   dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to Install Xorg? (Only if you use arch)" 8 60 && install_xorg=y 
    }

modifyfstab() { \
   dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to Modify fstab and add my NFS shares this is mostly for my personal use so most should say no here" 8 60 && modify_fstab="y" || modify_fstab="n" 
    }
browser() { \

declare -a browser_number=( 

"qutebrowser 1"
"brave 2"
"chromium 3"
"firefox 4"
)



until [ $browser = "1" -o $browser = "2" -o $browser = "3" -o $browser = "4" ] ; do
        browser_list=$(printf '%s\n' "${browser_number[@]}")
        
        browser=$(dialog --colors --title "\Z7\ZbBrowser" --inputbox "\Z4Which Browser do you want to use as your default?\nAnswer with a number between 1-4\n$browser_list" --output-fd 1 8 60  ) 


       if [ $browser = "1" -o $browser = "2" -o $browser = "3" -o $browser = "4" ] ; then
           
            echo " &> /dev/null" 
       else
       
            errormsg
       
       fi



done

browser=$(printf '%s\n' "${browser_number[@]}" | grep $browser | sed -e "s/[1-9]*//g")

}

installqtile() { \
       
sudo apt install python3-pip python3-cairocffi
pip install xffib
pip install qtile


ln -s $HOME/karl/.local/bin/qtile

xsession_content=$(printf "[Desktop Entry]\n
Name=qtile\n
Comment=This will start qtile wm\n
Exec=/usr/bin/qtile start\n
Type=Application"\n )


printf '%s\n' "${xsession_content[@]}" | sed '/^ *$/d' > /usr/share/xsessions/qtile.desktop

}


defaultsettings


 

if [ $use_default = "y" -o $use_default = "Y" ] ; then
       
       install_docker="y"
       install_portainer="n"
       install_xorg="n"
       install_fonts="n"
       modify_fstab="n"
       browser="qutebrowser"
else 

       installdocker 
       
       if [ $install_docker = "y" ] ; then
       
          installportainer 
       fi
       
       if [ $os = "Arch" ] ; then      

          installxorg 
       
       fi
       
       installfonts 

       modifyfstab 

       browser
       

fi


Lastchance || error "User choose to exit"

clear

config="$HOME/dotfiles"
files="$HOME/dotfiles/setup-files"


fstab="$HOME/dotfiles/setup-files/fstab"
pacman_conf="$HOME/dotfiles/setup-files/pacman.conf"
pacman="$HOME/dotfiles/setup-files/pacman"
dnf="$HOME/dotfiles/setup-files/dnf"
apt="$HOME/dotfiles/setup-files/apt"



declare -a config_config=(

"$config/.config/fish"
"$config/.config/kitty"
"$config/.config/nvim"
"$config/.config/oh-my-zsh/"
"$config/.config/qtile"
"$config/.config/qutebrowser"
"$config/.config/bash"
"$config/.config/alacritty"
"$config/.config/rofi"
"$config/.config/starship.toml"

)

declare -a config_home=(

"$config/.tmux.conf.local"
"$config/.xmonad"
"$config/.zshrc"
"$config/.bashrc"


)
declare -a config_sudo=(

"$config/.config/lightdm"

)



#Optional
cronfile="$config/.config/cron"

moveconfig(){ \
            
        for cc in "${config_config[@]}" ; do
        
              cp -r $cc $HOME/.config/

        done
        
        for ca in "${config_home[@]}" ; do
        
              cp -r $ca $HOME/
       
        done
        for cs in "${config_sudo[@]}" ; do
        
              sudo cp -r $cs /etc 
        done



}



#Cloning my repo if its needed
if [ -d $HOME/setup ] ; then
         
         sleep 1 
         clear
else

         if [ -d /etc/dnf ] ; then  
          
                  sudo dnf -y install git zsh
                  [ $? != "0" ] && error "GIT failed to install....... aborting"   
                  
         fi
         
         if [ -d /etc/apt ] ; then 

                  sudo apt -y install git zsh &> /dev/null
                  [ $? != "0" ] && error "GIT failed to install....... aborting"   
         fi  
         
         if [ -e /etc/pacman.conf ] ; then 

                  sudo pacman -S  --noconfirm --needed git zsh
                  [ $? != "0" ] && error "GIT failed to install....... aborting"  
         fi

                  #Clones the git hub repo so we can access all the files we need
                  echo "##########################################################"
                  echo "## Cloning My git repo to get all my config files ready ##"
                  echo "##########################################################"
                  
                  git clone https://github.com/phoenix988/setup $HOME/setup || error "Cloning repo failed......aborting" 

                  
                  sleep 2 
                  clear
                  
                  #Will exit the script if for some reason the cloning fail
fi 
echo "#########################################################"
echo "## Cloning My dotfiles repo to get all my config files ##"
echo "#########################################################"

[ -d $HOME/dotfiles ] || git clone https://github.com/phoenix988/dotfiles.git $HOME/dotfiles 

sleep 2
clear
       
echo "###################################################"
echo "## Installing curl zsh wget if its not installed ##"
echo "###################################################"
[ -d /etc/dnf ] && sudo dnf install -y  curl zsh wget  
[ -d /etc/apt ] && sudo apt install -y  curl  zsh wget  
[ -e /etc/pacman.conf ] && sudo pacman -Sy curl zsh wget --noconfirm --needed  

sleep 2
clear


if [ -e $HOME/.config/oh-my-zsh/oh-my-zsh.sh ] ; then

     sleep 2
     clear
else

     echo "########################"
     echo "## Installs OH-MY-ZSH ##"
     echo "########################"
     sleep 2

     [ -d $HOME/.config ] || mkdir $HOME/.config
     
     [ -d $HOME/.config/oh-my-zsh/ ] && sudo rm -rf $HOME/.config/oh-my-zsh/
     
     sh -c "$(curl -fsSL https://raw.githubusercontent.com/phoenix988/setup/main/ohmyzsh.sh)" "" --unattended 
     
     sudo chown karl:karl -R $HOME/.config/oh-my-zsh
     
     sleep 2 
     clear 
    
     #Installs ZSH plugins
     echo "################################"
     echo "## Installs OH-MY-ZSH Plugins ##"
     echo "################################"
     
     sleep 2 

     git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.config/oh-my-zsh/zsh-autosuggestions  
     
     git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.config/oh-my-zsh/zsh-syntax-highlighting 
     
     sleep 2 
     clear     
     
     echo "###################################"
     echo "## Changing Default Shell to ZSH ##"
     echo "###################################"
     usermod=$(sudo usermod -s /bin/zsh $USER)       
     
     sleep 2
     clear
fi

#Installs the starship prompt if its not installed   
#This will print the version of starship Installed 
#But if it's not installed this script will go ahead and install it

if [ -e /usr/local/bin/starship ] ; then
     
     sleep 2
     clear

else 


     echo "#######################"
     echo "## Installs Starship ##"
     echo "#######################"
     sleep 2
     $HOME/setup/starship.sh --yes  

     sleep 2
     clear

fi 
   
#Clones oh my tmux
echo "#########################"
echo "## Installs OH-MY-TMUX ##"
echo "#########################"
sleep 2
[ -d $HOME/.tmux ] || git clone https://github.com/gpakosz/.tmux.git  $HOME/.tmux 
clear

#Only links .tmux.conf if it doesnt exist already
echo "#############################################"
echo "## Creates HOME/.tmux/.tmux.conf if needed ##"
echo "#############################################"

sleep 2

[ -e $HOME/.tmux.conf ] || ln -s $HOME/.tmux/.tmux.conf $HOME/.tmux.conf 

clear   

#Edits the fstab if needed to add my script folder
#Temporarily change ownership on fstab
#And checks your fstab to see if you already have the correct entries
#and also if you can reach my NFS share if its offline and unavailable
#and if its unavailable it won't modify the fstab
if [ "$modify_fstab" = "y" ] ; then 

       echo "######################################################################"
       echo "## Creates script folder in HOMEFOLDER if they dont't exist already ##"
       echo "######################################################################"

       sleep 2
       
       clear
       #This will create .dmenu and .scripts in $HOME if they dont exist
       [ -d $HOME/.scripts ] || mkdir $HOME/.scripts
       [ -d $HOME/.dmenu ] || mkdir $HOME/.dmenu
       
       #Checks if I need to modify the fstab
       check_script=$(cat /etc/fstab | awk '/.scripts/ {print $1}')
       check_dmenu=$(cat /etc/fstab | awk '/.dmenu/ {print $1}')
       ping 192.168.1.10 -c 1 &> /dev/null 
       
      if [ $? = "0" ] ; then 
         
            echo "#########################################"
            echo "## Ping Succeded, Modifying your fstab ##"
            echo "#########################################"
            
            sleep 2
            
            #Modifying the fstab but this is temporaily and it will change back to default permissions
            sudo chown $USER:$USER /etc/fstab
               
            [ -z $check_script ] && cat $fstab | awk '/.scripts/' >> /etc/fstab && \
            printf "\nadding $( cat $fstab | awk '/.scripts/ {print $1}' ) to the fstab\n"
            
            [ -z $check_dmenu ] && cat $fstab | awk '/.dmenu/' >> /etc/fstab && \
            printf "\nadding $( cat $fstab | awk '/.dmenu/ {print $1}' ) to the fstab\n"
            
            #Change the ownership back to root on fstab 
            sudo chown root:root /etc/fstab
            
            #mounting everything from fstab
            echo "#####################################"
            echo "## Running mount -a on all entries ##"
            echo "#####################################"
            sudo mount -a
            
            else 
                   
            echo "######################################"
            echo "## Ping failed nothing will be done ##"
            echo "######################################"
               
      fi

fi
   
#Checks what package manager you have and then install some packages
#also it will do some other things based on what distro you have

#This is for apt or ubuntu/debian based distros
if [ -d /etc/apt ] ; then

         #Installs packages from the apt file
         #just add the package name to that list if you want 
         #this script to install it for you
         echo "############################################################"
         echo "## Installing apt packages from my package list if needed ##"
         echo "############################################################"
         sudo apt install $(cat $apt) -y 2> $HOME/.apt.error
       
         
         #Installs glorious theme for lightdm
         #And also installs lightdm webkit2 greeter so the theme will work
         [ -e ./lightdm-webkit2-greeter_2.2.5-1+15.31_amd64.deb ] && wget https://download.opensuse.org/repositories/home:/antergos/xUbuntu_17.10/amd64/lightdm-webkit2-greeter_2.2.5-1+15.31_amd64.deb
         sudo dpkg -i ./lightdm-webkit2-greeter_2.2.5-1+15.31_amd64.deb
         rm -rf lightdm-webkit2-greeter_2.2.5-1+15.31_amd64.deb
         
         git clone --recursive https://github.com/thegamerhat/lightdm-glorious-webkit2  $HOME/lightdm-glorious-webkit2
         [ -d /usr/share/lightdm-webkit/themes ] || sudo mkdir -p /usr/share/lightdm-webkit/themes
         
         sudo cp -r $HOME/lightdm-glorious-webkit2 /usr/share/lightdm-webkit/themes/glorious
         sudo rm -rf $HOME/lightdm-glorious-webkit2 


         if [ -e /usr/bin/lsd ] ; then
              
              wget https://github.com/Peltoche/lsd/releases/download/0.22.0/lsd-musl_0.22.0_amd64.deb && sudo dpkg -i ./lsd-musl_0.22.0_amd64.deb
              rm -rf lsd-musl_0.22.0_amd64.deb
         
         fi 





         #This will check if nano is installed or not 
         remove_nano=$(dpkg -l | grep nano )

         #We dont ever wanna use nano
         #so lets remove it if its installed
         [ -z "$remove_nano" ] || sudo apt purge nano &> /dev/null
         
         #This will link nanos binary to neovim so even if you 
         #type nano it will open neovim
         [ -e /usr/bin/nano ] && sudo rm /usr/bin/nano
         sudo ln -s /usr/bin/nvim /usr/bin/nano &> /dev/null 
         
         if [ $install_docker = "y" ] ; then
                
                #Installs docker 
                sudo apt install docker.io -y

                #this will start the docker daemon if its not running
                sudo systemctl enable --now docker &> /dev/null

                #adds the user to the docker group
                sudo usermod -aG docker $USER &> /dev/null
         fi     

fi

#This is for dnf or fedora based distros
if [ -d /etc/dnf ] ; then

         #checks if its fedora you are running 
         fedora=$(cat /etc/os-release | awk -F = '$1 =="ID" {print $2}' )
         
         #Installs packages from the dnf file
         #just add the package name to that list if you want 
         #this script to install it for you
         echo "############################################################"
         echo "## Installing DNF packages from my package list if needed ##"
         echo "############################################################"
         sudo dnf install $(cat $dnf) -y 2> $HOME/.dnf.error
         
         sleep 2
         clear

         #This will install docker if you are running fedora
         #it will check for the distro id and if the id is fedora
         #this script will install docker
         if [ $install_docker = "y" ] ; then

                     [ "$fedora" = "fedora" ] && 
                      echo "#############################################################################"
                      echo "## I see you're using fedora ... so adding docker repo and installs it.... ##"
                      echo "#############################################################################"
                     sudo dnf config-manager \
                     --add-repo \
                     https://download.docker.com/linux/fedora/docker-ce.repo  && \
                     sudo dnf install docker-ce docker-ce-cli containerd.io -y  && \
                     sudo systemctl enable --now docker &> /dev/null && sudo usermod -aG docker $USER                      
                     
                     sleep 2
                     clear
                     
            fi 
            #We dont ever wanna use nano
            #so lets remove it if its installed
            echo "####################################"
            echo "## Removing nano if its installed ##"
            echo "####################################"
            [ -e /usr/bin/nano ] && sudo dnf remove nano 
            
            sleep 1
            
            #This will link nanos binary to neovim so even if you 
            #type nano it will open neovim
            echo "#########################################################################"
            echo "## Linking neovim to nano.. even if you type nano neovim will be used. ##"
            echo "## Cause well... I dont know how to use nano                           ##"
            echo "#########################################################################"
            [ -e /usr/bin/nano ] && sudo rm /usr/bin/nano
            sudo ln -s /usr/bin/nvim /usr/bin/nano &> /dev/null 
               
               sleep 2 
               clear
fi

#This is for pacman or arch based distors
if [ -e /etc/pacman.conf ] ; then
    
         echo "###################################"
         echo "## Adding Pacman Repo if neeeded ##"
         echo "###################################"
         #This will check if you already have andonties repo in your pacman.conf 
         check_pacman=$(cat /etc/pacman.conf | awk '/andontie-aur/' | \
         sed -e 's/\[//g' -e 's/\]//g')
         #modifying pacman.conf if needed 
         #Temporarily change ownership on pacman.conf
         sudo chown $USER:$USER /etc/pacman.conf
         #If check_pacman is empty then it will add the repos to pacman.conf
         [ -z $check_pacman ] && cat $pacman_conf >> /etc/pacman.conf
         #Change the ownsership back to root on pacman.conf
         sudo chown root:root /etc/pacman.conf
        
         sleep 2
         clear
         
         #Installs packages from the pacman file
         #just add the package name to that list if you want 
         #this script to install it for you
         echo "###############################################################"
         echo "## Installing pacman packages from my package list if needed ##"
         echo "###############################################################"
         sudo pacman -Sy --overwrite "*" $(cat $pacman) --needed --noconfirm  2> $HOME/.pacman.error

         sleep 2
         clear
         
         #Installs Docker if you said yes 
         if [ "$install_docker" = "y" ] ; then 

                  echo "#########################################################################"
                  echo "## Installing Docker and configuring usergroups and enabling autostart ##"
                  echo "#########################################################################"
                  sudo pacman -S docker --needed --noconfirm 

                  #adds the user to the docker group
                  sudo usermod -aG docker $USER 

                  #this will start the docker daemon if its not running
                  sudo systemctl enable --now docker 
         fi

         sleep 2
         clear


         #installs xorg if you said yes 
         if [ "$install_xorg"  = "y" ] ; then

                  echo "###################################################"
                  echo "## Installing xorg and display manager if needed ##"
                  echo "###################################################"
                  sleep 2 
                  sudo pacman -S xorg lightdm --needed --noconfirm 

                  checks_gpu=$(neofetch | grep GPU | awk '{print $2}') 
                  sudo systemctl enable lightdm 
         
         if [ "$checks_gpu" = "NVIDIA" ] ; then 


                  sudo pacman -S nvidia --noconfirm --needed   

         fi


         
         fi
         
         echo "###########################################"
         echo "# Installing pfetch,autofs,mutt-wizard and#" 
         echo "# lightdm themes if needed using paru     #" 
         echo "###########################################"
         sleep 2 
         paru -S --overwrite "*" pfetch --needed --noconfirm 
         paru -S --overwrite "*" autofs --needed --noconfirm 
         paru -S --overwrite "*" uwufetch --needed --noconfirm 
         paru -S --overwrite "*" mutt-wizard --needed --noconfirm 
         paru -S --overwrite "*" lightdm-webkit2-greeter --needed --noconfirm 
         paru -S --overwrite "*" lightdm-webkit2-theme-glorious --needed --noconfirm 
       
         clear 
        
         #This will deactivate logins for root
         echo "#####################################################################"
         echo "##  Deactivating root account for security reasons , if its needed ##" 
         echo "#####################################################################"
         check_root_if_activated=$(grep "root" /etc/passwd | awk -F : '{print $NF}' | awk -F / '{print $NF}')
         [ $check_root_if_activated != "nologin" ] && usermod_root=$(sudo usermod -s /usr/bin/nologin root | awk '{print $3}')       

         sleep 2
         clear
fi





check_sudoers=$(sudo grep -e '^%wheel\|^%sudo' /etc/sudoers | awk '/NOPASSWD/' )

if [ -z $check_sudoers ] ; then
echo "############################"
echo "## Modifying Sudoers file ##"
echo "############################"
echo '%wheel ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo &> /dev/null 
echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo &> /dev/null 
fi

sleep 1
clear

      
   
#Copying all my config files from the git repo I cloned to your
#Personal config folder 
echo "################################"
echo "## Installing my config files ##" 
echo "################################"

moveconfig

sleep 4
clear
#copying cron files if you said yes to it
if [ "$cron_install" = "y" ] ; then

     echo "##########"
     echo "## cron ##" 
     echo "##########"
     sudo cp -r $cronfile/* /var/spool/cron
     sleep 2 
     clear
fi


#only link neovim to vim if neovim is installed 
if [ -e /usr/bin/nvim ] ; then
        


        echo "##################################"
        echo "## Linking neovim to vi and vim ##"
        echo "##################################"
        #This will link vim to neovim
        #so even if you run vim it will open in neovim
        [ -e /usr/bin/vim ] && sudo rm /usr/bin/vim
         sudo ln -s /usr/bin/nvim /usr/bin/vim
         
        #This will link vi to neovim
        #so even if you run vi it will open in neovim
        [ -e /usr/bin/vi ] && sudo rm /usr/bin/vi
         sudo ln -s /usr/bin/nvim /usr/bin/vi
                
fi

sleep 2
clear

#This will create .config folder for root
echo "#######################################################"
echo "## Creates config folder for root if it doesnt exist ##"
echo "#######################################################"
[ -d /root/.config ] || sudo mkdir /root/.config &> /dev/null
sleep 2
clear
#This will link the neovim config to the root USER
#so neovim will have the same config even if you edit something as root
echo "##############################################"
echo "## Linking neovim config to root so it uses ##" 
echo "## the same neovim config as the user       ##"
echo "##############################################"

[ -d $HOME/.config/nvim ] && sudo ln -s $HOME/.config/nvim /root/.config/nvim &> /dev/null && \

sleep 2
clear
#Change grub theme to CyberRE or you can chnage to whatever theme that you prefer 
check_grub_theme=$(cat /etc/default/grub | grep GRUB_THEME | awk -F = '{print $1}' | grep -v "^#")
grub=$(ls /boot | grep grub)
[ -d /boot/$grub/themes ] || sudo mkdir /boot/$grub/themes
sudo cp -r $HOME/dotfiles/grub-themes/* /boot/$grub/themes

if [ "$check_grub_theme" = "GRUB_THEME" ] ; then
          echo "#########################"
          echo "## Updating grub theme ##" 
          echo "#########################"
          sudo sed -i -e "s|GRUB_THEME=\"\/boot\/$grub\/themes\/CyberRe\/theme.txt\"|GRUB_THEME=\"\/boot\/$grub\/themes\/CyberRe\/theme.txt|g" /etc/default/grub &> /dev/null

else 
 
          echo "#########################"
          echo "## Updating grub theme ##" 
          echo "#########################"
          sudo chown karl:karl /etc/default/grub
          echo "GRUB_THEME=/boot/grub/themes/CyberRe/theme.txt" >> /etc/default/grub
          sudo chown root:root /etc/default/grub
fi

sudo  grub-mkconfig -o /boot/grub/grub.cfg 2> /dev/null
sudo  grub2-mkconfig -o /boot/grub2/grub.cfg 2> /dev/null

sleep 2
clear

#Move my wallpapers to Pictures folder
[ -d "$HOME/Pictures" ] || mkdir $HOME/Pictures

if [ -d $HOME/Pictures/Wallpapers/ ] ; then
   
      
      
      printf "\n"
  
else

       echo "##############################################################"
       echo "## Cloning my wallpaper repo and move them to HOME/Pictures ##"
       echo "##############################################################"
       sleep 2
       clear
       git clone https://github.com/phoenix988/wallpapers.git $HOME/wallpapers &> /dev/null
       cp -r $HOME/wallpapers/Wallpapers $HOME/Pictures &> /dev/null
       cp $HOME/setup/.fehbg $HOME/ &> /dev/null
       rm -rf $HOME/wallpapers &> /dev/null
       [ -d /var/pictures ] || sudo mkdir /var/pictures
       sudo ln -s $HOME/pictures/Wallpapers /var/pictures/Wallpapers
       
   fi

#Creates my personal scripts folder in usr/bin if it doesn't exis
if [ "$modify_fstab" = "n" ] ; then

       clear
       echo "###############################"
       echo "## Moving My scripts to HOME ##"
       echo "###############################"
       sleep 2
       clear
       cp -r $HOME/dotfiles/.scripts $HOME/dotfiles/.dmenu $HOME/ 
       cp -r $HOME/dotfiles/Documents  $HOME/ 
       chmod +x -R $HOME/.dmenu 
       chmod +x -R $HOME/.scripts 
       
       [ -d /usr/bin/myscripts ] || sudo ln -s $HOME/.scripts/activated /usr/bin/myscripts
  
fi 


echo "##############################"
echo "## Updating default browser ##"
echo "##############################"
sleep 2
clear
check_browser=$(grep "^browser" $HOME/dotfiles/.dmenu//dm-openweb_fullscreen  | awk -F "=" '{print $2}' | sed -e 's/"//g')
sed -i -e "s|$check_browser|$browser|g" $HOME/.dmenu/dm-openweb_fullscreen

check_browser=$(grep -i "^#BROWSER" $HOME/.config/qtile/config.py | awk '{print $3}')
sed -i -e "s|$check_browser|$browser|g" $HOME/.config/qtile/config.py
#This will install portainer agent on the host
#only if choose to install docker on the system
if [ "$install_portainer" = "y" ] ; then
       
    docker -v &> /dev/null 

       if [ $? = "0" ] ; then
              echo "###########################################################" 
              echo "## Installing Portainer agent so you can use this server ##"
              echo "## For docker containers only if its needed              ##"
              echo "###########################################################" 
              sleep 2    
              portainer_agent=$(sudo docker ps | awk '$NF == "portainer_agent" {print $NF}' 2> /dev/null)
              
              sudo docker volume create portainer_data_agent 
              
              [ "$portainer_agent" != "portainer_agent" ] && \
              sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always \
              -v /var/run/docker.sock:/var/run/docker.sock  \
              -v portainer_data_agent:/var/lib/docker/volumes portainer/agent  
       fi
fi

sleep 2
clear

if [ "$install_fonts" = "y" ] ; then

    echo "#####################"
    echo "## Moving my fonts ##"
    echo "#####################"   
    git clone https://github.com/phoenix988/fonts.git $HOME/fonts 
    
    [ -d $HOME/.local/share/fonts ] || mkdir $HOME/.local/share/fonts
    sudo cp -r $HOME/fonts/fonts/* $HOME/.local/share/fonts

    rm -rf $HOME/fonts &> /dev/null

fi

rm -rf $HOME/dotfiles

fi
