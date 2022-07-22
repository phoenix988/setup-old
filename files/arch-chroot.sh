#!/bin/bash              

               user=karl
               hostname=test


               printf "\nUpdating locales\n"
               sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
               echo "LANG=en_GB.UTF-8" > /etc/locale.conf
               locale-gen
               printf "\nsetting up timezone\n"
               ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
               printf "\nenabling networking\n"
               systemctl enable NetworkManager
               printf "\nadding user\n" 
               useradd $user
               passwd $user
               printf "\nsetting up hostname\n"
               echo "$hostname" > /etc/hostname
               
               exit
