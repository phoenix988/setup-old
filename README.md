# Setup - Utility that will configure my desktop

Utility that will configure your desktop using my configuration files

My plan is to make this work on any distro but currently its just in testing phase and isn't that stable, But this script will work best on arch for now

# OBS This is a work in progress
Currently testing on 

Arch 

Ubuntu

Debian

Fedora

## What this script does

This script includes the following
All config files will be pulled from my dotfiles repository

Qtile - Window Manager

Kitty - Terminal emulator

Neovim - Text Editor

Neomutt (If you use arch it will also install muttwizard) - Terminal Mail Client

SDDM - Displaymanager

Rofi - Run Launcher
![rofi](https://i.imgur.com/qy1yTFX.png)

Slock - Lockscreen

Tmux with OH-MY-TMUX - Terminal Multiplexer 

Vifm - Terminal FileManager

PcManFM - Graphical FileManager

OH-MY-ZSH - Plugin Manager for ZSH

Fish,Zsh and Bash - you get to choose the Default

Choose between firefox,qutebrowser,chromium or brave as your browser

Grub Theme (Only have it tested and working on Debian and Arch)

OBS this script also deactivates root password prompt when using sudo this will be a security risk I just prefer it because I'm lazy


## This repo is mainly for me to make it easier for me when I reinstall

## The run.sh script is broken it doesnt work, I also wanted to be able to run this script on a remote machine but at the moment that doesnt work


## In order to use this script follow these steps

1. git clone https://github.com/phoenix988/setup.git 
2. cd setup
3. ./config.sh


And lastly just follow the prompts this script will ask you some questions before it run


