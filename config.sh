#!/bin/bash
   
   #adding some long paths to variables so it will be easier to use
   fstab="/home/karl/setup/files/fstab"
   pacman_conf="/home/karl/setup/files/pacman.conf"
   pacman="/home/karl/setup/files/pacman"
   dnf="/home/karl/setup/files/dnf"
   apt="/home/karl/setup/files/apt"
   
   #config path
   config="$HOME/setup/config"

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

   #checks the OS that you are running
   check_os=$(cat /etc/os-release | awk -F = '/^NAME/ {print $2}' | sed 's/"//g' | awk '{print $1}') 
  
   #Asks if you want to install docker
   until [ "$install_docker" = "y" -o "$install_docker" = "n"  ]
   do
            read -p "do you want to install docker? [y/n]: " install_docker 
   
   if [ "$install_docker" = "y" -o "$install_docker" = "n" ] ; then 
            echo "" &> /dev/null
   else
            printf "\nPlease type y or n\n"
   fi 

   done
   
   if [ $install_docker = "y" ] ; then
  
   #Asks if you want to configure portainer agent but only if you choose to install docker   
   until [ "$install_portainer" = "y" -o "$install_portainer" = "n"  ]
   do
            read -p "do you want to configure portainer agent? [y/n]: " install_portainer 
   
   if [ "$install_portainer" = "y" -o "$install_portainer" = "n" ] ; then 
            echo "" &> /dev/null
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
            echo "" &> /dev/null
   else
            printf "\nPlease type y or n\n"
   fi 
   
   done 
   
   until [ "$full_install_arch" = "y" -o "$full_install_arch" = "n" ]  

   do 
            read -p "You're using Arch...Do yo want to do a complete setup ?
it will configure timezone for you etc [y/n]:" full_install_arch
  
    if [ "$full_install_arch" = "y" -o "$full_install_arch" = "n" ] ; then 
            echo "" &> /dev/null
   else
            printf "\nPlease type y or n\n"
   fi 

   done

   fi 
   

   if [ $full_install_arch = "y" ] ; then
              
               while [ -z "$check_drive" ] ; do 
               read -p "Which Partition do you want to use for the Install?: " drive
               check_drive=$(lsblk $drive 2> /dev/null)
                
               if [ -z "$check_drive" ] ; then

                  printf "\nPlease type a proper drive..Cant find the drive you specified\n"

               else
                
                  echo "" &> /dev/null

               fi
              
               done
              
               user=karl
               hostname=test
               
               sudo mount $drive /mnt 
               pacstrap /mnt base-devel grub btrfs-progs networkmanager systemd
               printf "\nGenerating fstab\n"
               genfstab -U /mnt >> /mnt/etc/fstab
               arch-chroot /mnt
               printf "\nUpdating locales\n"
               sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
               echo "LANG=en_GB.UTF-8" > /etc/locale.conf
               locale-gen
               printf "\nsetting up timezone\n"
               ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
               printf "\nebaling networking\n"
               systemctl enable NetworkManager
               printf "\nadding user\n" 
               useradd $user
               passwd $user
               printf "\nsetting up hostname\n"
               echo "$hostname" > /etc/hostname
                
               exit

   fi
   
   until [ "$modify_fstab" = "y" -o "$modify_fstab" = "n"  ]
   
   do
    
            read -p "Do you want to add my NFS shares to your fstab?
You can check what will be added in the files folder [y/n]: " modify_fstab 
   
   if [ "$modify_fstab" = "y" -o "$modify_fstab" = "n" ] ; then 
            echo "" &> /dev/null
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
       
   #This makes sure oh my zsh and zsh will be configured 
   #and setup correctly using my config files

   printf "\nChecks if zsh is installed\n" 
    
   if [ -e /usr/bin/zsh ] ; then
       
          printf "\nzsh already Installed\n"
          sleep 2
   
   else 

          [ -d /etc/dnf ] && sudo dnf install -y zsh    &> /dev/null 
          [ -d /etc/apt ] && sudo apt install -y zsh    &> /dev/null 
          [ -e /etc/pacman.conf ] && sudo pacman -S zsh &> /dev/null 

   fi

   printf "\nChecks if oh-my-zsh is installed\n" 

   if [ -d $HOME/.config/oh-my-zsh ] ; then     
     
          printf "\nOh my Zsh is Installed\n"
          
          sleep 2
   
   else

          #Installs oh my zsh
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
           
          [ -d $HOME/.config ] || mkdir $HOME/.config
          sudo cp -r $HOME/.oh-my-zsh $HOME/.config/oh-my-zsh
          
          [ -e $HOME/.oh-my-zsh ] && rm -rf $HOME/.oh-my-zsh
          
          sudo chown karl:karl $HOME/.config/oh-my-zsh
          #Install some zsh plugins     
          git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.config/oh-my-zsh/zsh-autosuggestions

          git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.config/oh-my-zsh/zsh-syntax-highlighting

   fi
   
   #This will change the default shell to zsh
   which zsh &> /dev/null 

   [ $? = "0" ] && usermod=$(sudo usermod -s /bin/zsh $USER | awk '{print $3}') || printf "\n ZSH is not installed wont change shell\n"
   printf "\n Changing Default shell to zsh if needed\n"
   
   #removes oh my zsh if its for some reason exist in the wrong directory
   [ -e $HOME/.oh-my-zsh ] && rm -rf $HOME/.oh-my-zsh
   
   #Installs the starship prompt if its not installed   
   #This will print the version of starship Installed 
   #But if it's not installed this script will go ahead and install it
   printf "\n Checks if starship is installed .. and installs it if its not\n"
   
   sleep 2
   
   which starship &> /dev/null

   [ $? != "0" ] && wget https://starship.rs/install.sh &> /dev/null 
   
   [ -e $HOME/install.sh ] && sudo chmod 755 ./install.sh && sudo ./install.sh --yes > /dev/null && rm $HOME/install.sh 

   #Clones oh my tmux
   [ -d $HOME/.tmux ] || git clone https://github.com/gpakosz/.tmux.git  $HOME/.tmux &> /dev/null

   #Only links .tmux.conf if it doesnt exist already
   printf "\nLinkink $HOME/.tmux/.tmux.conf if needed\n"
   
   sleep 2
   
   [ -e $HOME/.tmux.conf ] || ln -s $HOME/.tmux/.tmux.conf $HOME/.tmux.conf 

   #This will create .dmenu and .scripts in $HOME if they dont exist
   printf "\nCreating script folders in $HOME if they doesnt exist already\n"
   sleep 2
   [ -d $HOME/.scripts ] || mkdir $HOME/.scripts
   [ -d $HOME/.dmenu ] || mkdir $HOME/.dmenu

   #Edits the fstab if needed to add my script folder
   #Temporarily change ownership on fstab
   #And checks your fstab to see if you already have the correct entries
   #and also if you can reach my NFS share if its offline and unavailable
   #and if its unavailable it won't modify the fstab
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
       
            printf "\n Adding Pacman Repos if needed\n"
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
            [ -z $errorpacman ] || printf "\n You got some error installing packages here is the log \n\n $HOME/.pacman.error"
       
            #Installs Docker if you said yes 
            if [ $install_docker = "y" ] ; then 

                     printf "\nInstalling Docker\n"
                     sudo pacman -S docker &> /dev/null

                     #adds the user to the docker group
                     sudo usermod -aG docker $USER &> /dev/null

                     #this will start the docker daemon if its not running
                     sudo systemctl enable --now docker &> /dev/null

            fi
   
            #installs xorg if you said yes 
            if [ $install_xorg  = "y" ] ; then
   
                     printf "\nInstalls xorg\n"
                     
                     sudo pacman -S xorg --needed --noconfirm &> /dev/null
            


            
            fi
            #Installs pfetch
            printf "\nInstalling pfetch and autofs if its no installed already using paru\n" 
            paru -S pfetch --needed --noconfirm &> /dev/null
            paru -S autofs --needed --noconfirm &> /dev/null
            paru -S mutt-wizard --needed --noconfirm &> /dev/null
            
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
   printf "\n\n Creates config folder for root if it doesnt exist\n"
   [ -d /root/.config ] && sudo mkdir /root/.config &> /dev/null

   #This will link the neovim config to the root USER
   #so neovim will have the same config even if you edit something as root
   printf "\nLinking neovim config to root so it uses the same neovim config as the user\n"
   
   [ -d $HOME/.config/nvim ] && sudo ln -s $HOME/.config/nvim /root/.config/nvim &> /dev/null && \
   sleep 2

   #This will install portainer agent on the host
   #only if choose to install docker on the system
   if [ $install_portainer = "y" ] ; then
          
       docker -v &> /dev/null 

          if [ $? = "0" ] ; then
             
                 printf "\nInstalling Portainer agent so you can use this server\nFor docker containers only if its needed"
                 
                 portainer_agent=$(sudo docker ps | awk '$NF == "portainer_agent" {print $NF}' 2> /dev/null)
                 
                 sudo docker volume create portainer_data_agent &> /dev/null
                 
                 [ "$portainer_agent" != "portainer_agent" ] && \
                 sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v portainer_data_agent:/var/lib/docker/volumes portainer/agent &> /dev/null 
          fi
   fi
