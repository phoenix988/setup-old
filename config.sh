#!/bin/bash
   
        

error() { \
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}

      
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

      
pacman -S --noconfirm --needed wget archlinux-keyring

[ -e $HOME/arch-chroot.sh ] || wget https://raw.githubusercontent.com/phoenix988/setup/main/arch-chroot.sh &> /dev/null

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
    
Lastchance || error "User choose to exit"

fi
               if [ $check_fstype = "btrfs" ] ; then
                   
                   sudo mount $drive /mnt &> /dev/null   
                   sudo btrfs subvolume create /mnt/@ &> /dev/null
                   sudo btrfs subvolume create /mnt/@home &> /dev/null
                   sudo umount /mnt &> /dev/null
                   sudo mount -o subvol=@ $drive /mnt &> /dev/null

               else 
               
                  sudo mount $drive /mnt 
               
               fi
               
               pacstrap /mnt base-devel \
               grub btrfs-progs networkmanager \
               systemd efibootmgr linux linux-firmware \
               arch-install-scripts systemd-sysvcompat git || error "Pacstrap Failed to install everything"
               
               [ "$check_fstype" = "btrfs" ] && sudo mount -o subvol=@home $drive /mnt/home

               printf "\nGenerating fstab\n"
               genfstab -U /mnt >> /mnt/etc/fstab
              
               chmod 775 $HOME/arch-chroot.sh
               cp $HOME/arch-chroot.sh /mnt/root/ &> /dev/null

               #Runs everything in chroot mode to configure the rest
               arch-chroot /mnt echo "user=$user" >> /mnt/root/.bashrc 
               arch-chroot /mnt echo "host_name=$host_name" >> /mnt/root/.bashrc 
               arch-chroot /mnt echo "bios_version=$bios_version" >> /mnt/root/.bashrc 
               arch-chroot /mnt echo "efidrive=$efidrive" >> /mnt/root/.bashrc 
               arch-chroot /mnt echo "biosdrive=$biosdrive" >> /mnt/root/.bashrc 
               arch-chroot /mnt sh $HOME/arch-chroot.sh
               printf "chroot is done"
 
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
        dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to InstallDocker?" 8 60 && install_docker=y 
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
   dialog --colors --title "\Z7\ZbCustomize the script" --yes-label "Yes" --no-label "No" --yesno "\Z4Do you want to Modify fstab and add my NFS shares this is mostly for my personal use so most should say no here" 8 60 && modify_fstab=y 
    }


defaultsettings


 

if [ $use_default = "y" -o $use_default = "Y" ] ; then
       
       install_docker="y"
       install_portainer="n"
       install_xorg="n"
       install_fonts="n"
       modify_fstab="n"
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
       

fi

clear

Lastchance || error "User choose to exit"

#adding some long paths to variables so it will be easier to use
fstab="$HOME/dotfiles/setup-files/fstab"
pacman_conf="$HOME/dotfiles/setup-files/pacman.conf"
pacman="$HOME/dotfiles/setup-files/pacman"
dnf="$HOME/dotfiles/setup-files/dnf"
apt="$HOME/dotfiles/setup-files/apt"

#config path
config="$HOME/dotfiles"
files="$HOME/dotfiles/setup-files"

#config_files
tmuxconflocal="$config/.tmux.conf.local"
xmonad="$config/.xmonad"
zshrc="$config/.zshrc"
fish="$config/.config/fish"
kitty="$config/.config/kitty"
nvim="$config/.config/nvim"
myzsh="$config/.config/myzsh/aliases.sh"
qtile="$config/.config/qtile"
qutebrowser="$config/.config/qutebrowser"
rofi="$config/.config/rofi"
starship="$config/.config/starship.toml"
lightdm="$config/.config/lightdm"
archchroot="$config/.scripts/activated/arch-chroot.sh"
cronfile="$config/.config/cron"

  
   #Cloning my repo if its needed
   if [ -d $HOME/setup ] ; then
            printf "\nMy repo already exist in $HOME so no need to clone.....\n"

            sleep 2
   else

            if [ -d /etc/dnf ] ; then  
             
                     sudo dnf -y install git zsh &> /dev/null
                     [ $? != "0" ] && printf "\nGIT failed to install....... aborting" && exit  
            fi
            
            if [ -d /etc/apt ] ; then 

                     sudo apt -y install git zsh &> /dev/null
                     [ $? != "0" ] && printf "\nGIT failed to install....... aborting" && exit  
            fi  
            
            if [ -e /etc/pacman.conf ] ; then 

                     sudo pacman -S  --noconfirm --needed git zsh  &> /dev/null
                     [ $? != "0" ] && printf "\nGIT failed to install....... aborting" && exit  
            fi
   
                     #Clones the git hub repo so we can access all the files we need
                     printf "\nCloning My git repo to get all my config files ready"
                     
                     git clone https://github.com/phoenix988/setup $HOME/setup > /dev/null 
                     
                     #Will exit the script if for some reason the cloning fail
                     [ $? != "0" ] && printf "\n cloning repo failed......aborting" && exit
   fi 
      
   [ -d $HOME/dotfiles ] || git clone https://github.com/phoenix988/dotfiles.git $HOME/dotfiles &> /dev/null

   if [ -e /usr/bin/curl ] ; then
       
          printf "\ncurl already Installed\n"
          sleep 2
   
   else 

          [ -d /etc/dnf ] && sudo dnf install -y  curl  &> /dev/null 
          [ -d /etc/apt ] && sudo apt install -y  curl  &> /dev/null 
          [ -e /etc/pacman.conf ] && sudo pacman -S curl --noconfirm --needed &> /dev/null 
.config/
   fi



   if [ -e /usr/bin/wget ] ; then
       
          printf "\nwget already Installed\n"
          sleep 2
   
   else 

          [ -d /etc/dnf ] && sudo dnf install -y wget &> /dev/null 
          [ -d /etc/apt ] && sudo apt install -y wget &> /dev/null 
          [ -e /etc/pacman.conf ] && sudo pacman -S wget --noconfirm --needed &> /dev/null 

   fi

    
   if [ -e /usr/bin/zsh ] ; then
       
          printf "\nzsh already Installed\n"
          sleep 2
   
   else 

          [ -d /etc/dnf ] && sudo dnf install -y zsh  &> /dev/null 
          [ -d /etc/apt ] && sudo apt install -y zsh  &> /dev/null 
          [ -e /etc/pacman.conf ] && sudo pacman -S zsh  --noconfirm --needed &> /dev/null 

   fi

   
          if [ -e $HOME/.config/oh-my-zsh/oh-my-zsh.sh ] ; then

               printf "\nOH my zsh already installed\n"


          else

          
          #Installs oh my zsh
          printf "\nInstalls oh my zsh\n"
          
          sleep 2
          
          [ -d $HOME/.config ] || mkdir $HOME/.config
          
          [ -d $HOME/.config/oh-my-zsh/ ] && sudo rm -rf $HOME/.config/oh-my-zsh/
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/phoenix988/setup/main/ohmyzsh.sh)" "" --unattended > /dev/null

          sudo chown karl:karl -R $HOME/.config/oh-my-zsh
          
          #Install some zsh plugins     
          git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.config/oh-my-zsh/zsh-autosuggestions &> /dev/null

          git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.config/oh-my-zsh/zsh-syntax-highlighting &> /dev/null

   
          printf "\nChanging default shell to ZSH\n"
          usermod=$(sudo usermod -s /bin/zsh $USER)       
          
          fi

    #Installs the starship prompt if its not installed   
    #This will print the version of starship Installed 
    #But if it's not installed this script will go ahead and install it

    if [ -e /usr/local/bin/starship ] ; then

       printf "\nStarship already Installed\n"
    
    else 
    
       printf "\nInstalls starship\n"
    
      $HOME/setup/starship.sh --yes &> /dev/null 
    
    fi 
   
   #Clones oh my tmux
   [ -d $HOME/.tmux ] || git clone https://github.com/gpakosz/.tmux.git  $HOME/.tmux &> /dev/null

   #Only links .tmux.conf if it doesnt exist already
   printf "\nLinkink $HOME/.tmux/.tmux.conf if needed\n"
   
   sleep 2
   
   [ -e $HOME/.tmux.conf ] || ln -s $HOME/.tmux/.tmux.conf $HOME/.tmux.conf 

   

   #Edits the fstab if needed to add my script folder
   #Temporarily change ownership on fstab
   #And checks your fstab to see if you already have the correct entries
   #and also if you can reach my NFS share if its offline and unavailable
   #and if its unavailable it won't modify the fstab
   if [ $modify_fstab = "y" ] ; then 
   
   printf "\nCreating script folders in $HOME if they doesnt exist already\n"
   sleep 2
   #This will create .dmenu and .scripts in $HOME if they dont exist
   [ -d $HOME/.scripts ] || mkdir $HOME/.scripts
   [ -d $HOME/.dmenu ] || mkdir $HOME/.dmenu
  
   #Checks if I need to modify the fstab
   check_script=$(cat /etc/fstab | awk '/.scripts/ {print $1}')
   check_dmenu=$(cat /etc/fstab | awk '/.dmenu/ {print $1}')
   ping 192.168.1.10 -c 1 &> /dev/null 
   
   if [ $? = "0" ] ; then 
         
            printf "\nPing succeded , Modifying your fstab if needed\n"  
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
            printf "\nRunning mount -a to mount all entris from the fstab\n"
            sudo mount -a
         
   else 
       
            printf "\nPing failed Nothing will be done\n"  
   
   fi

   fi
   
   #Checks what package manager you have and then install some packages
   #also it will do some other things based on what distro you have
   
   #This is for apt or ubuntu/debian based distros
   if [ -d /etc/apt ] ; then
   
            #Installs packages from the apt file
            #just add the package name to that list if you want 
            #this script to install it for you
            printf "\nInstalling apt packages from my package list if needed\n"
            sudo apt install $(cat $apt) -y &> /dev/null
            
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
            printf "\nInstalling dnf packages from my package list if needed\n"
            sudo dnf install $(cat $dnf) -y > /dev/null 2> $HOME/.dnf.error
            
            [ -e $HOME/.dnf.error ] && errordnf=$(cat $HOME/.dnf.error)
            [ -z $errordnf ] || printf "\n You got some error installing packages here is the log \n\n $HOME/.dnf.error"
            

            #This will install docker if you are running fedora
            #it will check for the distro id and if the id is fedora
            #this script will install docker
            if [ $install_docker = "y" ] ; then

                     [ "$fedora" = "fedora" ] && 
                     printf "\n I see you're using fedora ... so adding docker repo and installs it....\n"
                     sudo dnf config-manager \
                     --add-repo \
                     https://download.docker.com/linux/fedora/docker-ce.repo > /dev/null && \
                     sudo dnf install docker-ce docker-ce-cli containerd.io -y &> /dev/null && \
                     sudo systemctl enable --now docker &> /dev/null && sudo usermod -aG docker $USER &> /dev/null
            
            fi 
            #We dont ever wanna use nano
            #so lets remove it if its installed
            printf "\n Removing nano if its installed\n"
            [ -e /usr/bin/nano ] && sudo dnf remove nano &> /dev/null 
            
            #This will link nanos binary to neovim so even if you 
            #type nano it will open neovim
            printf "\n Linking neovim to nano.. even if you type nano neovim will be used\nCause well... I dont know how to use nano\n"
            [ -e /usr/bin/nano ] && sudo rm /usr/bin/nano
            sudo ln -s /usr/bin/nvim /usr/bin/nano &> /dev/null 
                
   fi

   #This is for pacman or arch based distors
   if [ -e /etc/pacman.conf ] ; then
       
            printf "\nAdding Pacman Repos if needed\n"
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
            
            #Installs packages from the pacman file
            #just add the package name to that list if you want 
            #this script to install it for you
            printf "\nInstalling pacman packages from my package list if needed\n"
            sudo pacman -Sy $(cat $pacman) --needed --noconfirm > /dev/null 2> $HOME/.pacman.error
            [ -e $HOME/.pacman.error ] && errorpacman=$(cat $HOME/.pacman.error) 
            [ -z "$errorpacman" ] || printf "\nYou got some error installing packages here is the log \n$HOME/.pacman.error\n"
       
            #Installs Docker if you said yes 
            if [ $install_docker = "y" ] ; then 

                     printf "\nInstalling Docker\n"
                     sudo pacman -S docker --noconfirm &> /dev/null

                     #adds the user to the docker group
                     sudo usermod -aG docker $USER &> /dev/null

                     #this will start the docker daemon if its not running
                     sudo systemctl enable --now docker &> /dev/null

            fi
   
            #installs xorg if you said yes 
            if [ "$install_xorg"  = "y" ] ; then
   
                     printf "\nInstalling xorg\n"
                     
                     sudo pacman -S xorg lightdm --needed --noconfirm &> /dev/null

                     checks_gpu=$(neofetch | grep GPU | awk '{print $2}') 
           
            if [ "$checks_gpu" = "NVIDIA" ] ; then 

                     sudo pacman -S nvidia --noconfirm --needed   

            fi


            
            fi
            #Installs pfetch
            printf "\nInstalling pfetch,autofs,mutt-wizard and lightdm themes if needed using paru\n" 
            paru -S pfetch --needed --noconfirm &> /dev/null
            paru -S autofs --needed --noconfirm &> /dev/null
            paru -S mutt-wizard --needed --noconfirm &> /dev/null
            paru -S lightdm-webkit2-greeter --needed --noconfirm &> /dev/null
            paru -S lightdm-webkit2-theme-glorious --needed --noconfirm &> /dev/null
           
            #This will deactivate logins for root
            printf "\nDeactivating root account for security reasons , if its needed\n"
            check_root_if_activated=$(grep "root" /etc/passwd | awk -F : '{print $NF}' | awk -F / '{print $NF}')
            [ $check_root_if_activated != "nologin" ] && usermod_root=$(sudo usermod -s /usr/bin/nologin root | awk '{print $3}')       

               fi
      
   
   #Copying all my config files from the git repo I cloned to your
   #Personal config folder 
   printf "\nMoving all my config files to the right folders\n" 
   
   printf "\ntmux_conf.local"
   cp -r $tmuxconflocal $HOME/
   printf "\nxmonad"
   cp -r $xmonad $HOME/
   printf "\n.zshrc"
   cp -r $zshrc $HOME/
   printf "\nfish"
   cp -r $fish $HOME/.config/
   printf "\nkitty"
   cp -r $kitty $HOME/.config/
   printf "\nnvim"
   cp -r $nvim $HOME/.config/
   printf "\naliases.sh"
   cp -r $myzsh $HOME/.config/oh-my-zsh/
   printf "\nqtile"
   cp -r $qtile $HOME/.config/
   printf "\nqutebrowser"
   cp -r $qutebrowser $HOME/.config/
   printf "\nrofi"
   cp -r $rofi $HOME/.config/
   printf "\nstarship.toml\n"
   cp -r $starship $HOME/.config/

   #Copy files that requrie sudo permission
   sudo cp -r $lightdm /etc

   #copying cron files if you said yes to it
   if [ "$cron_install" = "y" ] ; then

        sudo cp -r $cronfile/* /var/spool/cron

   fi




   #only link neovim to vim if neovim is installed 
   if [ -e /usr/bin/nvim ] ; then

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

   #This will create .config folder for root
   printf "\n\nCreates config folder for root if it doesnt exist\n"
   [ -d /root/.config ] || sudo mkdir /root/.config &> /dev/null

   #This will link the neovim config to the root USER
   #so neovim will have the same config even if you edit something as root
   printf "\nLinking neovim config to root so it uses the same neovim config as the user\n"
   
   [ -d $HOME/.config/nvim ] && sudo ln -s $HOME/.config/nvim /root/.config/nvim &> /dev/null && \
   sleep 2

   #Change grub theme to CyberRE or you can chnage to whatever theme that you prefer 
   check_grub_theme=$(cat /etc/default/grub | grep GRUB_THEME | awk -F = '{print $1}' | grep -v "^#")
   sudo cp -r $HOME/dotfiles/grub-themes/* /boot/grub/themes

   if [ "$check_grub_theme" = "GRUB_THEME" ] ; then
 
             printf "\nUpdating grub theme\n" 
             sudo sed -i 's/GRUB_THEME=\"\/boot\/grub\/themes\/CyberRe\/theme.txt\"/GRUB_THEME=\"\/boot\/grub\/themes\/CyberRe\/theme.txt/g' /etc/default/grub &> /dev/null
   
   else 
    
             printf "\nUpdating grub theme\n" 
             sudo chown karl:karl /etc/default/grub
             echo "GRUB_THEME=/boot/grub/themes/CyberRe/theme.txt" >> /etc/default/grub
             sudo chown root:root /etc/default/grub
   fi

      sudo  grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null


   #Move my wallpapers to Pictures folder
   [ -d "$HOME/Pictures" ] || mkdir $HOME/Pictures
   
   if [ -d $HOME/Pictures/Wallpapers/ ] ; then
   
      
      
      printf "\n"
  
   else

       printf "\nCloning my wallpaper repo and move them to $HOME/Pictures\n"
       git clone https://github.com/phoenix988/wallpapers.git $HOME/wallpapers &> /dev/null
       cp -r $HOME/wallpapers/Wallpapers $HOME/Pictures &> /dev/null
       cp $HOME/setup/.fehbg $HOME/ &> /dev/null
       rm -rf $HOME/wallpapers &> /dev/null
   fi
  #Creates my personal scripts folder in usr/bin if it doesn't exis
   if [ $modify_fstab = "n" ] ; then

        git clone https://github.com/phoenix988/dotfiles.git $HOME/dotfiles &> /dev/null

        sudo cp -r $HOME/dotfiles/.scripts $HOME/dotfiles/.dmenu $HOME/ 
       
        [ -d /usr/bin/myscripts ] || sudo ln -s $HOME/.scripts/activated /usr/bin/myscripts
  
   fi 

   #This will install portainer agent on the host
   #only if choose to install docker on the system
   if [ "$install_portainer" = "y" ] ; then
          
       docker -v &> /dev/null 

          if [ $? = "0" ] ; then
             
                 printf "\nInstalling Portainer agent so you can use this server\nFor docker containers only if its needed\n"
                 
                 portainer_agent=$(sudo docker ps | awk '$NF == "portainer_agent" {print $NF}' 2> /dev/null)
                 
                 sudo docker volume create portainer_data_agent &> /dev/null
                 
                 [ "$portainer_agent" != "portainer_agent" ] && \
                 sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v portainer_data_agent:/var/lib/docker/volumes portainer/agent &> /dev/null 
          fi
   fi


   if [ $install_fonts = "y" ] ; then

       git clone https://github.com/phoenix988/fonts.git $HOME/fonts &> /dev/null
       
       sudo cp -r $HOME/fonts/fonts/* /usr/share/fonts

       rm -rf $HOME/fonts &> /dev/null

   fi
   
   rm -rf $HOME/dotfiles

   fi
