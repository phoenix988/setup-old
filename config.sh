#!/bin/bash
   
        hostname=$(hostname 2> /dev/null)
   
      if [ "$hostname" = "archiso" ] ; then 
       
      pacman -S --noconfirm --needed wget
    
      wget https://github.com/phoenix988/setup/raw/main/files/arch-chroot.sh 


              
               while [ -z "$check_drive" ] ; do 
               read -p "Which Partition do you want to use for the Install?: " drive
               check_drive=$(lsblk $drive 2> /dev/null)
               
               if [ -z "$check_drive" ] ; then

                  printf "\nPlease type a proper drive..Can't find the drive you specified\n"

               else
                
                  check_fstype=$(lsblk -f $drive | head -n2 | tail -n1 | awk '{print $2}' ) 
                  printf "\nChecks the filesystem"

               fi
              
               done
              
               if [ $check_fstype = "btrfs" ] ; then
                   
                   sudo mount $drive /mnt &> /dev/null   
                   sudo btrfs subvolume create /mnt/@ &> /dev/null
                   sudo btrfs subvolume create /mnt/@home &> /dev/null
                   sudo umount /mnt &> /dev/null
                   sudo mount -o subvol=@ $drive /mnt &> /dev/null

               else 
               
                  sudo mount $drive /mnt 
               
               fi
               
               pacstrap /mnt base-devel grub btrfs-progs networkmanager systemd efibootmgr linux linux-firmware arch-install-scripts systemd-sysvcompat git
               
               [ $check_fstype = "btrfs" ] && sudo mount -o subvol=@home $drive /mnt/home

               printf "\nGenerating fstab\n"
               genfstab -U /mnt >> /mnt/etc/fstab
               
               cp $HOME/arch-chroot.sh /mnt/root/ &> /dev/null
               printf "\nNow you need to run the script located in /root/arch-chroot.sh\n"
               arch-chroot /mnt 
               printf "chroot is done"
 
               exit
 
         else
   
   #adding some long paths to variables so it will be easier to use
   fstab="/home/karl/setup/files/fstab"
   pacman_conf="/home/karl/setup/files/pacman.conf"
   pacman="/home/karl/setup/files/pacman"
   dnf="/home/karl/setup/files/dnf"
   apt="/home/karl/setup/files/apt"
   
   #config path
   config="$HOME/setup/config"
   files="$HOME/setup/files"

   #config_files
   tmuxconflocal="$config/.tmux.conf.local"
   xmonad="$config/.xmonad"
   zshrc="$config/.zshrc"
   fish="$config/fish"
   kitty="$config/kitty"
   nvim="$config/nvim"
   myzsh="$config/myzsh/aliases.sh"
   qtile="$config/qtile"
   qutebrowser="$config/qutebrowser"
   rofi="$config/rofi"
   starship="$config/starship.toml"
   lightdm="$config/lightdm"
   archchroot="$files/arch-chroot.sh"
   cronfile="$config/cron"

   #checks the OS that you are running
   check_os=$(cat /etc/os-release | awk -F = '/^NAME/ {print $2}' | sed 's/"//g' | awk '{print $1}') 
   
   #Asks if you want to install docker
   until [ "$install_docker" = "y" -o "$install_docker" = "n"  ]
   do
            read -p "do you want to install docker? [y/n]: " install_docker 
   
   if [ "$install_docker" = "y" -o "$install_docker" = "n" ] ; then 
            printf "\n"
   else
            printf "\nPlease type y or n\n"
   fi 

   done
   
   if [ $install_docker = "y" ] ; then
  
         #Asks if you want to configure portainer agent but only if you choose to install docker   
         until [ "$install_portainer" = "y" -o "$install_portainer" = "n"  ]
         do
                  read -p "Do you want to configure portainer agent? [y/n]: " install_portainer 
         
         if [ "$install_portainer" = "y" -o "$install_portainer" = "n" ] ; then 
                  
                  printf "\n"
         else
                  printf "\nPlease type y or n\n"
         fi 
         done
   fi  

   if [ $check_os = "Arch" ] ; then
  
   #Asks if you want to install Xorg if you run arch   
         until [ "$install_xorg" = "y" -o "$install_xorg" = "n"  ]
         
         do
          
                  read -p "Do you want to install Xorg? [y/n]: " install_xorg 
         
         if [ "$install_xorg" = "y" -o "$install_xorg" = "n" ] ; then 
                  
                  printf "\n"
         else
                  printf "\nPlease type y or n\n"
         fi 
         
         done 
   

   fi 
   
   
   until [ "$modify_fstab" = "y" -o "$modify_fstab" = "n"  ]
   
   do
    
            read -p "Do you want to add my NFS shares to your fstab?
You can check what will be added in the files folder [y/n]: " modify_fstab 
   
   if [ "$modify_fstab" = "y" -o "$modify_fstab" = "n" ] ; then 
            printf "\n"
   else
            printf "\nPlease type y or n\n"
   fi 
   
   done 
   
   until [ "$install_fonts" = "y" -o "$install_fonts" = "n"  ]
   do
            read -p "Do you want to get all my fonts [y/n]?: " install_fonts 
   
   if [ "$install_fonts" = "y" -o "$install_fonts" = "n" ] ; then 
            printf "\n"
   else
            printf "\nPlease type y or n\n"
   fi 

   done

   
   clear


   #Will exit the script if you are root since I dont recommend running this as root
   [ $UID = "0" ] && printf "Don't run this script as root ..... aborting" && exit
  
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

                     sudo pacman -S  --noconfirm git zsh  &> /dev/null
                     [ $? != "0" ] && printf "\nGIT failed to install....... aborting" && exit  
            fi
   
                     #Clones the git hub repo so we can access all the files we need
                     printf "\nCloning My git repo to get all my config files ready"
                     
                     git clone https://github.com/phoenix988/setup $HOME/setup > /dev/null 
                     
                     #Will exit the script if for some reason the cloning fail
                     [ $? != "0" ] && printf "\n cloning repo failed......aborting" && exit
   fi 
       

   if [ -e /usr/bin/curl ] ; then
       
          printf "\ncurl already Installed\n"
          sleep 2
   
   else 

          [ -d /etc/dnf ] && sudo dnf install -y  curl  &> /dev/null 
          [ -d /etc/apt ] && sudo apt install -y  curl  &> /dev/null 
          [ -e /etc/pacman.conf ] && sudo pacman -S curl --noconfirm --needed &> /dev/null 

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
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/phoenix988/setup/main/files/ohmyzsh.sh)" "" --unattended > /dev/null

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
    
      $HOME/setup/files/starship.sh --yes &> /dev/null 
    
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
                     
                     sudo pacman -S xorg --needed --noconfirm &> /dev/null

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
   sudo cp -r $HOME/setup/files/grub-themes/* /boot/grub/themes

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
   printf "\nCloning my wallpaper repo and move them to $HOME/Pictures\n"
   [ -d "$HOME/Pictures" ] || mkdir $HOME/Pictures
   git clone https://github.com/phoenix988/wallpapers.git $HOME/wallpapers &> /dev/null
   cp -r $HOME/wallpapers/Wallpapers $HOME/Pictures &> /dev/null
   cp $HOME/setup/config/.fehbg $HOME/ &> /dev/null
   rm -rf $HOME/wallpapers &> /dev/null

  #Creates my personal scripts folder in usr/bin if it doesn't exis
   if [ $modify_fstab = "n" ] ; then

        git clone https://github.com/phoenix988/dotfiles.git $HOME/dotfiles &> /dev/null

        sudo cp -r $HOME/dotfiles/.scripts $HOME/dotfiles/.dmenu $HOME/ 
       
        [ -d /usr/bin/myscripts ] || sudo ln -s $HOME/.scripts/activated /usr/bin/myscripts

        rm -rf $HOME/dotfiles &> /dev/null
  
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

   fi
