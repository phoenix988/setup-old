#!/bin/bash              
user=$(awk -F = '{if(NR==1) print $NF}' /root/.bashrc )
host_name=$(awk -F = '{if(NR==2) print $NF}' /root/.bashrc )
bios_version=$(awk -F = '{if(NR==3) print $NF}' /root/.bashrc )
efidrive=$(awk -F = '{if(NR==4) print $NF}' /root/.bashrc )
biosdrive=$(awk -F = '{if(NR==5) print $NF}' /root/.bashrc )

 
echo "######################"
echo "## Updating Locales ##"
echo "######################"
sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
locale-gen &> /dev/null

sleep 2
clear

echo "#########################"
echo "## Setting up timezone ##"
echo "#########################"
ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime

sleep 2
clear

echo "#########################"
echo "## Enabling networking ##"
echo "#########################"
systemctl enable NetworkManager &> /dev/null

sleep 2
clear

echo "#################"
echo "## Adding User ##"
echo "#################"
useradd $user
passwd $user
usermod -aG wheel $user   
[ -d /home/$user ] || mkdir /home/$user
[ -d /home/$user ] && chown karl:karl -R /home/$user

sleep 2
clear

echo "############################"
echo "## Modifying Sudoers file ##"
echo "############################"
echo '%wheel ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo &> /dev/null 

sleep 2   
clear

echo "#########################"
echo "## Setting up Hostname ##"
echo "#########################"
echo "$host_name" > /etc/hostname

sleep 2
clear


if [ "$bios_version" = "U" -o "$bios_version" = "u" ] ; then

        [ -d /boot/EFI ] || mkdir /boot/EFI
        
        efifstype=$(lsblk -f $efidrive | awk '{print $2}' | grep -vi fstype) 
        [ $efifstype = "vfat" ] || mkfs -t vfat $efidrive
    
        mount $efidrive /boot/EFI &> /dev/null
      
        echo "#####################"
        echo "## Installing Grub ##"
        echo "#####################"


        grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB 
       
    
        genfstab -U / > /etc/fstab
        
        sleep 2
        clear
    
        if [ $? = "0" ] ; then

             echo "" &> /dev/null
       
        else 

             exit

         fi

else

        echo "#####################"
        echo "## Installing Grub ##"
        echo "#####################"
         
        grub-install --target=i386-pc $biosdrive 
        
        sleep 2
        clear 

        if [ $? = "0" ] ; then

            echo "" &> /dev/null
            
        else 

             exit

        fi


fi   
 
echo "#########################"
echo "## Generating grub.cfg ##"
echo "#########################"

grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null
