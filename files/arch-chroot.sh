#!/bin/bash              

               read -p "What name do you want on the user account?: " user
               read -p  "What Hostname do you want?: " hostname

               printf "\nUpdating locales\n"
               sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
               echo "LANG=en_GB.UTF-8" > /etc/locale.conf
               locale-gen
               printf "\nSetting up timezone\n"
               ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
               printf "\nEnabling networking\n"
               systemctl enable NetworkManager
               printf "\nAdding user\n" 
               useradd $user
               passwd $user
               
               printf "\nSetting up hostname\n"
               echo "$hostname" > /etc/hostname
               
