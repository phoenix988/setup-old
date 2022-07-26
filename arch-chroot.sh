#!/bin/bash              
               user=$(awk -F = '{if(NR==1) print $NF}') /root/.bashrc )
               host_name=$(awk -F = '{if(NR==2) print $NF}') /root/.bashrc )
               bios_version=$(awk -F = '{if(NR==3) print $NF}' /root/.bashrc )
               
                             
               if [ "$bios_version" = "u" -o "$bios_version" = "U" ] ; then

                  while [ -z "$check_efidrive" ] ; do 
              
                      read -p "What Partition do you want to be your EFI drive?: " efidrive
                      check_efidrive=$(lsblk $drive 2> /dev/null)
                     
                  if [ -z "$check_efidrive" ] ; then

                      printf "\nPlease type a proper drive..Cant find the drive you specified\n"

                  else
                   
                      echo "" &> /dev/null

                  fi

                  done
               
               else

                  while [ -z "$check_biosdrive" ] ; do 
              
                      read -p "What Partition do you want to be your BIOS drive?: " biosdrive
                      check_biosdrive=$(lsblk $biosdrive 2> /dev/null)
                     
                  if [ -z "$check_biosdrive" ] ; then

                      printf "\nPlease type a proper drive..Cant find the drive you specified\n"

                  else
                   
                      echo "" &> /dev/null

                  fi

                  done


               fi

                
               printf "\nUpdating locales\n"
               sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
               echo "LANG=en_GB.UTF-8" > /etc/locale.conf
               locale-gen &> /dev/null
               
               printf "\nSetting up timezone\n"
               ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime
               
               printf "\nEnabling networking\n"
               systemctl enable NetworkManager &> /dev/null
               
               printf "\nAdding user\n" 
               useradd $user
               passwd $user
               usermod -aG wheel $user   
               [ -d /home/$user ] || mkdir /home/$user
               [ -d /home/$user ] && chown karl:karl -R /home/$user

               printf "\nModifying sudoers file\n"
               echo '%wheel ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo &> /dev/null 

               printf "\nSetting up hostname\n"
               echo "$host_name" > /etc/hostname
            
              
               if [ "$bios_version" = "U" -o "$bios_version" = "u" ] ; then

                   [ -d /boot/EFI ] || mkdir /boot/EFI
                   
                   mount $efidrive /boot/EFI &> /dev/null
                   grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB > /dev/null 
                  

                   genfstab -U / > /etc/fstab


                   if [ $? = "0" ] ; then

                      echo "" &> /dev/null
                      
                   else 

                      exit

                   fi

               else

                   grub-install --target=i386-pc $biosdrive > /dev/null
               

                   if [ $? = "0" ] ; then

                      echo "" &> /dev/null
                      
                   else 

                      exit

                   fi


               fi   
               
               grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null
