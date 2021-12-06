#!/bin/bash

    #Will exit the script if you are root since
    [ $UID = "0" ] && printf "Don't run this script as root ..... exiting" && exit
    
    #adding some long paths to variables so it will be easier to use
    fstab="/mnt/Yandex.Disk/home/karl/scripts/configure_desktop/fstab"
    pacman_conf="/mnt/Yandex.Disk/home/karl/scripts/configure_desktop/pacman.conf"
    pacman="/mnt/Yandex.Disk/home/karl/scripts/configure_desktop/pacman"
    dnf="/mnt/Yandex.Disk/home/karl/scripts/configure_desktop/dnf"
    apt="/mnt/Yandex.Disk/home/karl/scripts/configure_desktop/apt"
    
    #Installs nfs-utils if its not already installed 
    #otherwise it wont be able to mount my nfs share
    [ -d /etc/apt ] && sudo apt install nfs-common -y &> /dev/null
    [ -d /etc/dnf ] && sudo dnf install nfs-utils -y &> /dev/null
    [ -e /etc/pacman.conf ] && sudo pacman -S nfs-utils --needed --noconfirm &> /dev/null
    
    #Mounts my cloud storage to /mnt
    printf "Mounting my nfs share where I have my config files stored\n"
    sudo umount /mnt &> /dev/null
    sudo mount -t nfs 10.0.0.1:/media/cloud_storage /mnt    

    #This checks your fstab to see if you already automount my nfs shares
    check_script=$(cat /etc/fstab | awk '/.scripts/ {print $1}')
    check_dmenu=$(cat /etc/fstab | awk '/.dmenu/ {print $1}')
    
    #Edits the fstab if needed
    #Temporarily change ownership on fstab
    sudo chown $USER:$USER /etc/fstab
       
    [ -z $check_script ] && cat $fstab | awk '/.scripts/' >> /etc/fstab && \
    printf "\nadding $( cat $fstab | awk '/.scripts/ {print $1}' ) to the fstab\n"
    
    [ -z $check_dmenu ] && cat $fstab | awk '/.dmenu/' >> /etc/fstab && \
    printf "\nadding $( cat $fstab | awk '/.dmenu/ {print $1}' ) to the fstab\n"
    
    #Change the ownership back to root on fstab 
    sudo chown root:root /etc/fstab


    
    #This will create .dmenu and .scripts in $HOME if they dont exist
    [ -d $HOME/.scripts ] || mkdir $HOME/.scripts
    [ -d $HOME/.dmenu ] || mkdir $HOME/.dmenu

    sudo mount -a

    
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
    
       #this will start the docker daemon if its not running
       sudo systemctl enable --now docker &> /dev/null
       

       #adds the user to the docker group
       sudo usermod -aG docker $USER &> /dev/null


    fi

    #This is for dnf or fedora based distros
    if [ -d /etc/dnf ] ; then
       
       #checks if its fedora you are running 
       fedora=$(cat /etc/os-release | awk -F = '$1 =="ID" {print $2}' )
       
       #Installs packages from the dnf file
       #just add the package name to that list if you want 
       #this script to install it for you
       printf "\nInstalling dnf packages from my package list if needed\n"
       sudo dnf install $(cat $dnf) -y &> /dev/null
      
       #This will install docker if you are running fedora
       #it will check for the distro id and if the id is fedora
       #this script will install docker
       [ "$fedora" = "fedora" ] && 
       sudo dnf config-manager \
       --add-repo \
       https://download.docker.com/linux/fedora/docker-ce.repo > /dev/null && \
       sudo dnf install docker-ce docker-ce-cli containerd.io -y &> /dev/null && \
       sudo systemctl enable --now docker &> /dev/null && sudo usermod -aG docker $USER &> /dev/null

       #We dont ever wanna use nano
       #so lets remove it if its installed
       sudo dnf remove nano &> /dev/null
       
       #This will link nanos binary to neovim so even if you 
       #type nano it will open neovim
       [ -e /usr/bin/nano ] && sudo rm /usr/bin/nano
       sudo ln -s /usr/bin/nvim /usr/bin/nano &> /dev/null 
    fi

    #This is for pacman or arch based distors
    if [ -e /etc/pacman.conf ] ; then
       
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
       sudo pacman -Sy $(cat $pacman) --needed --noconfirm &> /dev/null
      
       #Installs pfetch
       printf "\nInstalling pfetch if its no installed already using paru\n" 
       paru -S pfetch --needed --noconfirm &> /dev/null
      
       printf "\ncopying my lightdm config\n"
       sudo cp -r /mnt/Yandex.Disk/ansible/files/lightdm /etc/   

       #This will deactivate logins for root
       usermod_root=$(sudo usermod -s /usr/bin/nologin root | awk '{print $3}')       
      
       #adds the user to the docker group
       sudo usermod -aG docker $USER &> /dev/null

       #this will start the docker daemon if its not running
       sudo systemctl enable --now docker &> /dev/null
    fi

    #Installs the starship prompt if its not installed   
    #This will print the version of starship Installed 
    #But if it's not installed this script will go ahead and install it
    starship -V &> /dev/null

    [ $? != "0" ] && wget https://starship.rs/install.sh &> /dev/null 
    
    [ -e $HOME/install.sh ] && sudo chmod 755 ./install.sh && sudo ./install.sh --yes > /dev/null && rm $HOME/install.sh 
    

    #Rsyncs all my config files I need    
    printf "\nUsing rsync to copy all my config files to $HOME\n" 
    rsync -aAXv /mnt/Yandex.Disk/dotfiles/ $HOME &> /dev/null
       
    #Only creates .tmux.conf if it doesnt exist already
    [ -e $HOME/.tmux.conf ] || ln $HOME/.tmux/.tmux.conf $HOME/.tmux.conf || \
    printf "\nLinking $HOME/.tmux.conf\n"

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
   
    
    #This will change the default shell to zsh
    usermod=$(sudo usermod -s /bin/zsh $USER | awk '{print $3}')       

    [ "$usermod" = "changes" ] && printf "\ndefault shell is already zsh\n" || \
    printf "\nChanging default shell to zsh\n"


         

    #This will just mount everything you have in your fstab 
    printf "\nRunning mount -a to mount all entris from the fstab\n"

    #This will create .config folder for root
    sudo mkdir /root/.config &> /dev/null

    #This will link the neovim config to the root USER
    #so neovim will have the same config even if you edit something as root
    sudo ln -s $HOME/.config/nvim /root/.config/nvim &> /dev/null



    #This will install portainer agent on the host
    #only if docker is installed on the system
    docker -v &> /dev/null 

    if [ $? = "0" ] ; then

    portainer_agent=$(sudo docker ps | awk '$NF == "portainer_agent" {print $NF}' 2> /dev/null)
    sudo docker volume create portainer_data_agent &> /dev/null
    [ "$portainer_agent" != "portainer_agent" ] && \
    sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock  \
    -v portainer_data_agent:/var/lib/docker/volumes portainer/agent &> /dev/null 
    
    fi
