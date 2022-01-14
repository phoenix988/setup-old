#!/bin/bash

clear
read -p "Specify the hosts you want to run the script on ip or hostname? 
(seperated bya space): " -a choice
clear

DOCKER="no"
USERNAME=karl
HOSTS=$(printf '%s\n' "${choice[@]}")
SCRIPTCONTENT=$(cat config.sh )
SCRIPT="$SCRIPTCONTENT"  

for HOSTNAME in ${HOSTS} ; do

    ssh -l ${USERNAME} ${HOSTNAME} "${SCRIPT}"

done



    











