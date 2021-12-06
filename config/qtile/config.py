#
#
##____  _                      _      
#|  _ \| |__   ___   ___ _ __ (_)_  __
#| |_) | '_ \ / _ \ / _ \ '_ \| \ \/ /
#|  __/| | | | (_) |  __/ | | | |>  < 
#|_|   |_| |_|\___/ \___|_| |_|_/_/\_\
#                                     
# -*- coding: utf-8 -*-
import os
import re
import socket
import subprocess
from libqtile import qtile
from libqtile.config import Click, Drag, Group, KeyChord, Key, Match, Screen 
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook
from libqtile.lazy import lazy
from typing import List  # noqa: F401

#This is mainly for my dmenu script :)
#BROWSER = chromium
mod = "mod4"        # Sets mod key to SUPER/WINDOWS

myTerm = "kitty -e /usr/bin/myscripts/create_tmux_session.sh"      # My terminal of choice
myterm = "kitty -e zsh"

fileManager = "kitty -e vifmrun"              #My filemanagers both gui and terminal based
guifileManager = "pcmanfm /home/karl/Pictures/"

sysmon = "kitty -e btop" #This is for htop

browser1 = "chromium"       #Choose whatever browsers you prefer primary and secondary
browser2  = "chromium --new-window --app=https://duckduckgo.com"    

guieditor = "neovide"  #Choose your gui text editor
editor = "kitty -e vim" #My terminal based editor

virtman = "virt-manager"   #For my main hypervisor

backup = "sudo timeshift-gtk"   #Backup utility

#lockscreen = "i3lock -i /home/karl/Pictures/Anime/qwe_download.jpg  -C -k --wrong-text='Stay Away!' --greeter-text='Please enter your password'"
lockscreen =  "xfce4-screensaver-command -al"   #This is for my lockscreen

dmenu_path = "/home/karl/.dmenu" #Path to my dmenu scripts


#START_KEYS


keys = [
         
         
         #KEYS_GROUP Qtile
        Key([mod, "shift"], "r", #Restart  
             lazy.restart(),
             desc='Restart Qtile'
             ),
        Key([mod, "shift"], "q", #Logout
             lazy.shutdown(),
             desc='Shutdown Qtile'
             ),
        Key([mod, ], "u", #Show all the keybindings
             lazy.spawn("/home/karl/.config/qtile/qtile_keys.sh"),
             desc='Run Help Menu'
             ),
        Key([mod, ], "y", #show kitty bindings
             lazy.spawn("/home/karl/.config/kitty/kitty_keys.sh"),
             desc='Run Help Menu for kitty'
             ),
        Key(["mod1", "control" ], "i", #Lock the computer
             lazy.spawn(lockscreen),
             desc='Lock computer'
             ),

         #KEYS_GROUP Launch applications with super + key
         Key([mod, ], "r", #Run Rofi
              lazy.spawn("rofi -show drun  -display-drun \"Run : \" -drun-display-format \"{name}\""),
              desc='Run rofi'
             ),
         Key([mod, ], "s", #Take Screenshot
             lazy.spawn("flameshot gui"),
             desc='flameshot'
             ),
         Key([mod, ], "b", #Brave
             lazy.spawn(browser2),
             desc='Launch browser2'
             ),
         Key([mod, ], "i", #lxappearance
             lazy.spawn("lxappearance"),
             desc='theme settings'
             ),
         Key([mod, ], "o", #Launch OBS
             lazy.spawn("obs"),
             desc='OBS studio'
             ),
         Key([mod, ], "t", #Launch kitty
             lazy.spawn( myterm ),
             desc='kitty terminal'
             ),
         Key([mod], "Return", #Run Terminal
             lazy.spawn( myTerm ),
             desc='Launches My Terminal'
              ),
       #KEYS_GROUP Launch applications with super + shift + key
         Key([mod, "shift"], "y", #Run GUIEditor
             lazy.spawn( guieditor ),
             desc='Launches My guieditor'
             ),
         Key([mod, "shift"], "w", #Qutebrowser
             lazy.spawn(browser1),
             desc='Launch browser1'
             ),
         Key([mod, "shift"], "v", #Launch Virt-Manager
             lazy.spawn(virtman),
             desc='virt-manager'
             ),
         Key([mod, "shift"], "e", #Launch your filemanager
             lazy.spawn(fileManager),
             desc='File Manager'
             ),
         Key([mod, "shift"], "Return", #Launch your gui filemanager
             lazy.spawn(guifileManager),
             desc='Gui FileManager'
             ),
         Key([mod, "shift"], "g", #Launch kdenlive
             lazy.spawn("kdenlive"),
             desc='kdenlive'
             ),
         
      #KEYS_GROUP Launch application with alt + control + key
         Key(["mod1", "control"], "t", #Launch TaskManager
             lazy.spawn("lxtask"),
             desc='TaskManager'
             ),
         Key(["mod1", "control"], "s", #Launch Steam
             lazy.spawn("steam"),
             desc='Steam'
             ),
         Key(["mod1", "control"], "b", #Launch Timeshift
             lazy.spawn(backup),
             desc='Open timeshift'
             ),
         Key(["mod1", "control"], "p", #Launch Pavucontrol
             lazy.spawn("pavucontrol"),
             desc='Open Pavucontrol'
             ),
         Key(["mod1", "control"], "w", #Launch Bitwarden
             lazy.spawn("bitwarden-desktop"),
             desc='Bitwarden'
             ),

        

         #KEYS_GROUP Some of my custom scripts
        Key([mod, ],"F12", #Set a Random wallpaper
             lazy.spawn("/usr/bin/myscripts/set_random_bg"),
             desc='Set a random wallpaper'
             ),
        Key([mod, ],"F11", #Mount all my noauto mountpoints from fstab
             lazy.spawn("/usr/bin/myscripts/quick_mount_shortcut.sh"),
             desc='Mounts all my btrfs parent volumes with no auto'
             ),


        #KEYS_GROUP Media control
         Key([ ],"XF86AudioPlay", #Resume/Stop
             lazy.spawn("/usr/bin/myscripts/mediaplay"),
             desc='Pause'
             ),
         Key([ ],"XF86AudioNext", #Next
             lazy.spawn("/usr/bin/myscripts/medianext"),
             desc='Next'
             ),
         Key([ ],"XF86AudioPrev", #Prev
             lazy.spawn("/usr/bin/myscripts/mediaprev"),
             desc='Previous'
             ),
        #KEYS_GROUP Switch focus to specific monitor (out of two)
         Key([mod], "w", #Move focus to monitor 1
             lazy.to_screen(0),
             desc='Keyboard focus to monitor 1'
             ),
         Key([mod], "e", #Move focus to moinitor 2
             lazy.to_screen(1),
             desc='Keyboard focus to monitor 2'
             ),
        # Key([mod], "r",
         #    lazy.to_screen(2),
          #   desc='Keyboard focus to monitor 3'
           #  ),
         ### Switch focus of monitors
         Key([mod], "period", #Move focus to the next monitor
             lazy.next_screen(),
             desc='Move focus to next monitor'
             ),
         Key([mod], "comma", #Move focus to the prev monitor
             lazy.prev_screen(),
             desc='Move focus to prev monitor'
             ),
         #KEYS_GROUP Treetab controls
         Key([mod, "control"], "h", #Move up a section in treetab
             lazy.layout.move_left(),
             desc='Move up a section in treetab'
             ),
         Key([mod, "shift"], "l", #Move up a section in treetab
             lazy.layout.move_right(),
             desc='Move down a section in treetab'
             ),
         #KEYS_GROUP Window controls
         Key([mod], "Tab", #Toggle through layouts
             lazy.next_layout(),
             desc='Toggle through layouts'
             ),
         Key([mod,], "q", #Close window
             lazy.window.kill(),
             desc='Kill active window'
             ),
         Key([mod], "k", #Move focus down a pane
             lazy.layout.up(),
             desc='Move focus down in current stack pane'
             ),
         Key([mod], "j", #Move focus up a pane
             lazy.layout.down(),
             desc='Move focus up in current stack pane'
             ),
         Key([mod], "h", #Shrink window in tilling layout
             #lazy.layout.shrink(),
             #lazy.layout.decrease_nmaster(),
             lazy.layout.left(),
             desc='Shrink window (MonadTall), decrease number in master pane (Tile)'
             ),
         Key([mod], "l", #Expand window in tilling layout
             #lazy.layout.grow(),
             #lazy.layout.increase_nmaster(),
             lazy.layout.right(),
             desc='Expand window (MonadTall), increase number in master pane (Tile)'
             ),
         Key([mod], "n", #Normalize window size ratio
             lazy.layout.normalize(),
             desc='normalize window size ratios'
             ),
         Key([mod], "m", #Toggle window between minimum and maximum size
             lazy.layout.maximize(),
             desc='toggle window between minimum and maximum sizes'
             ),
         Key([mod], "f", #Toggle fullscreen
             lazy.window.toggle_fullscreen(),
             desc='toggle fullscreen'
             ),
         Key([mod, "shift"], "j", #Move windows down in current stack
             lazy.layout.shuffle_down(),
             lazy.layout.section_jown(),
             desc='Move windows down in current stack'
             ),
         Key([mod, "shift"], "k", #Move widnows up in current stack
             lazy.layout.shuffle_up(),
             lazy.layout.section_up(),
             desc='Move windows up in current stack'
             ),
         Key([mod, "shift"], "l", #Move windows down in current stack
             lazy.layout.shuffle_right(),
             #lazy.layout.section_jown(),
             desc='Move windows down in current stack'
             ),
         Key([mod, "shift"], "h", #Move widnows up in current stack
             lazy.layout.shuffle_left(),
             #lazy.layout.section_up(),
             desc='Move windows up in current stack'
             ),
         Key([mod, "shift"], "f", #Toggle floating
             lazy.window.toggle_floating(),
             desc='toggle floating'
             ),
         Key([mod, "mod1"], "l", #change the position of the window to the right
             lazy.layout.flip_right(),
             desc='change the position of the window to the right'
             ),
         Key([mod, "mod1"], "h", #change the position of the window to the left
             lazy.layout.flip_left(),
             desc='change the position of the window to the left'
             ),  
         Key([mod, "mod1"], "j", #change the position of the window down
             lazy.layout.flip_down(),
             desc='change the position of the window down'
             ),
         Key([mod, "mod1"], "k", #change the position of the window up
             lazy.layout.flip_up(),
             desc='change the position of the window up'
             ), 
         Key([mod, "control"], "h", #increase the size of the window to the left
             lazy.layout.grow_left(),
             desc='increase the size of the window to the left'
             ),
         Key([mod, "control"], "l", #increase the size of the window to the left
             lazy.layout.grow_right(),
             desc='increase the size of the window to the left'
             ),
         Key([mod, "control"], "j", #increase the size of the window downwards
             lazy.layout.grow_down(),
             desc='increase the size of the window downwards'
             ),
         Key([mod, "control"], "k", #increase the size of the window upwards
             lazy.layout.grow_up(),
             desc='increase the size of the window upwards'
             ),

        #KEYS_GROUP Stack controls
         Key([mod, "shift"], "Tab", #Switch which side main pane occupies, XmonadTall
             lazy.layout.rotate(),
             lazy.layout.flip(),
             desc='Switch which side main pane occupies (XmonadTall)'
             ),
         Key([mod], "space", #Switch window focus to other panes of stack
             lazy.layout.next(),
             desc='Switch window focus to other pane(s) of stack'
             ),
         Key([mod, "shift"], "space", #Toggle between split and unsplit sides of stack
             lazy.layout.toggle_split(),
             desc='Toggle between split and unsplit sides of stack'
             ),

         
        #KEYS_GROUP keybindings to control tmux without keychords
         Key(["control", "mod1"], "1", #Move to tmux window 1
             lazy.spawn("tmux select-window -t karl:1"),
             ),
         Key(["control", "mod1"], "2", #Move to tmux window 2
             lazy.spawn("tmux select-window -t karl:2"),
             ),
         Key(["control", "mod1"], "3", #Move to tmux window 3
             lazy.spawn("tmux select-window -t karl:3"),
             ),
         Key(["control", "mod1"], "4", #Move to tmux window 4
             lazy.spawn("tmux select-window -t karl:4"),
             ),
         Key(["control", "mod1"], "5", #Move to tmux window 5
             lazy.spawn("tmux select-window -t karl:5"),
             ),
         Key(["control", "mod1"], "6", #Move to tmux window 6
             lazy.spawn("tmux select-window -t karl:6"),
             ),
         Key(["control", "mod1"], "7", #Move to tmux window 7
             lazy.spawn("tmux select-window -t karl:7"),
             ),
         Key(["control", "mod1"], "8", #Move to tmux window 8
             lazy.spawn("tmux select-window -t karl:8"),
             ),
         Key(["control", "mod1"], "9", #Move to tmux window 9
             lazy.spawn("tmux select-window -t karl:9"),
             ),
         Key(["control", "mod1"], "x", #kill tmux pane
             lazy.spawn("tmux kill-pane -t karl"),
             ),
         Key(["control", "mod1"], "c", #create tmux window
             lazy.spawn("tmux new-window -t karl"),
             ),
         Key(["control", "mod1"], "v", #create horizontal split
             lazy.spawn("tmux splitw -h"),
             ),
         Key(["control", "mod1"], "s", #create vertical split
             lazy.spawn("tmux splitw -v"),
             ),
         Key(["control", "mod1"], "h", #prev pane
             lazy.spawn("/usr/bin/myscripts/next_tmux_pane.sh"),
             ),
         Key(["control", "mod1"], "l", #next pane
             lazy.spawn("/usr/bin/myscripts/prev_tmux_pane.sh"),
             ),
        #KEYS_GROUP Launch terminal based programs using the key chord CONTROL+e followed by 'key'
         KeyChord([mod], "z", [
                 Key([], "e", #Launch vifm
                     lazy.spawn(fileManager),
                desc='Open vifm file manager'
                 ),
                 Key([], "h", #Launch htop
                     lazy.spawn(sysmon),
                 desc='Open HTOP'
                 ),
                 Key([], "r", #Launch ranger
                     lazy.spawn("kitty  ranger"),
                 desc='Open RANGER'
                 ),
                 Key([], "v", #Launch your terminal editor
                     lazy.spawn(editor),
                 desc='launch your terminal editor'
                 ),
                 Key([], "t", #change rofi theme
                     lazy.spawn("rofi-theme-selector"),
                 desc='change rofi theme'
                 ),
         ]),
          


                #KEYS_GROUP Dmenu scripts launched using the key chord SUPER+p followed by 'key'
         KeyChord([mod], "p", [
             Key([], "e", #Choose config file to edit
                 lazy.spawn(dmenu_path + "/dm-editconfig"),
                 desc='Choose a config file to edit'
                 ),
             Key([], "m", #Mount your noauto mountpoints
                 lazy.spawn(dmenu_path + "/dm-mount"),
                 desc='Mount some harddrives using dmenu'
                 ),
             Key([], "k", #Kill a process
                 lazy.spawn(dmenu_path + "/dm-kill"),
                 desc='Kill processes via dmenu'
                 ),
             Key([], "r", #Sudo config files
                 lazy.spawn("sudo /home/karl/.dmenu/dm-editconfig"),
                 desc='Config a file that requires root'
                 ),
             Key([], "w", #Set wallpaper
                 lazy.spawn(dmenu_path + "/dm-set_wallpaper"),
                 desc='set a wallpaper'
                 ),
             Key([], "u", #Open a choosen program with dmenu
                 lazy.spawn(dmenu_path + "/dm-app"),
                 desc='Open a program with dmenu'
                 ),
             Key([], "a", #Change audio source
                 lazy.spawn(dmenu_path + "/dm-audioset"),
                 desc='choose audio source'
                 ),
             Key([], "o", #Open a website using your default browser
                 lazy.spawn(dmenu_path + "/dm-openweb"),
                 desc='Search your qutebrowser bookmarks and quickmarks'
                 ),
             Key([], "t", #Change theme for kitty
                 lazy.spawn(dmenu_path + "/dm-kittychangetheme"),
                 desc='Change kitty theme'
                 ),
             Key([], "l", #Change keyboard layout
                 lazy.spawn(dmenu_path + "/dm-layout"),
                 desc='Choose your keyboardlayout'
                 ),
             Key([], "v", #Connect to a vpn server using nordvpn
                 lazy.spawn(dmenu_path + "/dm-nordvpn"),
                 desc='Choose your VPN server for NordVPN'
                 ),
             Key([], "s", #search the web 
                 lazy.spawn(dmenu_path + "/dm-search"), 
                 desc='search the web'
                 ),
             Key([], "y", #print an emoji to the clipboard 
                 lazy.spawn(dmenu_path + "/dm-emojis"), 
                 desc='print an emoji to the clipboard'
                 ),
            # Key([], "f", #Displays the font on your system 
            #     lazy.spawn(dmenu_path + "/display_font"), 
            #     desc='displays the font on your system'
            #     ),
             Key([], "f", #opens my favorite websites in fullscreen mode with minimal UI 
                 lazy.spawn(dmenu_path + "/dm-openweb_fullscreen"), 
                 desc='open a website in fullscreen'
                 ),
             Key([], "g", #opens my favorite websites in fullscreen mode with minimal UI 
                 lazy.spawn(dmenu_path + "/dm-open_video"), 
                 desc='open a website in fullscreen'
                 ),
             Key([], "q", #Opens a VM of your choice in KVM 
                 lazy.spawn(dmenu_path + "/dm-open_virt_cons"), 
                 desc='Opens a VM of your choice in KVM'
                 ),
             Key([], "p", #menu to control music
                 lazy.spawn(dmenu_path + "/dm-play_pause"), 
                 desc='menu to control music'
                 ),],


         ),
                #KEYS_GROUP keychord  mod + z + key let you grow and shrink windows
   #   KeyChord([mod], "z", [
   #         Key([], "h", #Shrink window in tilling layout
   #          lazy.layout.shrink(),
   #          lazy.layout.decrease_nmaster(),
   #          desc='Shrink window (MonadTall), decrease number in master pane (Tile)'
   #          ),
   #         Key([], "l", #Expand window in tilling layout
   #          lazy.layout.grow(),
   #          lazy.layout.increase_nmaster(),
   #          desc='Expand window (MonadTall), increase number in master pane (Tile)'
   #          ),
   #         Key([], "k", #Move focus down a pane
   #          lazy.layout.up(),
   #          desc='Move focus down in current stack pane'
   #          ),
   #         Key([], "j", #Move focus up a pane
   #          lazy.layout.down(),
   #          desc='Move focus up in current stack pane'
   #          ),
   #         Key([], "g", #grow the window
   #             lazy.layout.grow()),
   #         Key([], "s", #shrink the window
   #             lazy.layout.shrink()),
   #         Key([], "n", #normalize the size of the window
   #             lazy.layout.normalize()), 
   #         Key([], "m", #maximize the size of the window
   #             lazy.layout.maximize())], 
   #         mode="Windows"
   # ),


                #KEYS_GROUP window modifier (mainly for bsp) launched using the key chord SUPER+shift+b followed by 'key'
      KeyChord([mod, "shift"], "b", [
            Key([], "k", #Move focus down a pane
                lazy.layout.up(),
             ),
            Key([], "j", #Move focus up a pane
                lazy.layout.down(),
             ),
            Key([], "h", #Move focus to the left
                lazy.layout.left(),
             ),
            Key([], "l", #Move focus to the right
                lazy.layout.right(),
             ),
            Key([], "d", #flip to the right
                lazy.layout.flip_right()),
            Key([], "a", #flip to the left
                lazy.layout.flip_left()),
            Key([], "w", #flip up
                lazy.layout.flip_up()), 
            Key([], "s", #flip down
                lazy.layout.flip_down()),
            Key([], "n", #normalize the size of the window
                lazy.layout.normalize()),
            Key(["shift"], "l", #move to the right
                lazy.layout.shuffle_right()),
            Key(["shift"], "h", #move to the left
                lazy.layout.shuffle_left()),
            Key(["shift"], "k", #move up
                lazy.layout.shuffle_up()), 
            Key(["shift"], "j", #move down
                lazy.layout.shuffle_down()),
            Key(["control"], "l", #grow the window to the right
                lazy.layout.grow_right()),
            Key(["control"], "h", #grow the window to the left
                lazy.layout.grow_left()),
            Key(["control"], "k", #grow the window up
                lazy.layout.grow_up()), 
            Key(["control"], "j", #grow the window down
                lazy.layout.grow_down())], 

            mode="BSP Window"
    ),


]


#END_KEYS

group_names = [("WWW", {'layout': 'bsp' ,'matches':[Match(wm_class=["Brave-browser" , browser1  , "Brave-browser-nightly", "Chromium" , "librewolf"])]}),
               ("DEV", {'layout': 'bsp','matches':[Match(wm_class=["neo"])]}),
               ("SYS", {'layout': 'bsp', 'matches':[Match(wm_class=["lxappearance", "TeamViewer"])]}),
               ("GAME", {'layout': 'max', 'matches':[Match(wm_class=["lutris" , "Steam" , "upc.exe" , "steam_proton" , "heroic"])]}),
               ("DOCS", {'layout': 'bsp', 'matches':[Match(wm_class=["re.sonny.Tangram"])]}),
               ("CHAT", {'layout': 'bsp', 'matches':[Match(wm_class=["discord" , "Franz" , "whatsapp-nativefier-d40211" , "altus" , "whatsdesk" , "whatsapp-for-linux"])]}),
               ("MUS", {'layout': 'bsp', 'matches':[Match(wm_class=["Spotify"])]}),
               ("VID", {'layout': 'bsp', 'matches':[Match(wm_class=["nemo"  , "io.github.celluloid_player.Celluloid" , "urxvt" , "obs"])]}),
               ("GFX", {'layout': 'bsp', 'matches':[Match(wm_class=["gimp-2.10","Gimp" ,"Cinelerra","Olive", "kdenlive" , "resolve" ])]})]


groups = [Group(name, **kwargs) for name, kwargs in group_names]

for i, (name, kwargs) in enumerate(group_names, 1):
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))        # Switch to another group
    keys.append(Key([mod, "shift"], str(i), lazy.window.togroup(name))) # Send current window to another group


layout_theme = {"border_width": 2,
                "margin": 5,
                "border_focus": "ff78c5",
                "border_normal": "1e1f28"
                }

layouts = [
    #layout.MonadWide(**layout_theme),
    layout.Bsp(**layout_theme,
                 lower_right = True,
                  fair = False  ),
                   
    #layout.Stack(stacks=2, **layout_theme),
    #layout.Columns(**layout_theme),
    layout.RatioTile(border_width = 2,
                     margin = 0,
                     ratio_increment = 0.2,
                     border_focus ="ff78c5",  
                     border_normal = "1e1f28", 

                      ),
                                               
    #layout.Tile(shift_windows=True,
    #ratio = "0,5",  **layout_theme),
    #layout.VerticalTile(**layout_theme),
    #layout.Matrix(**layout_theme),
    #layout.Zoomy(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
    layout.Stack(num_stacks=2,
                border_focus = "ff78c5",
                border_normal = "1e1f28",
                autosplit = False,
                fair = True ),
    #layout.RatioTile(**layout_theme),
    #  layout.TreeTab(
    #       font = "Ubuntu",
    #       fontsize = 10,
    #       sections = [""],
    #       section_fontsize = 10,
    #       border_width = 2,
    #       bg_color = "1e1f28",
    #       active_bg = "bd92f8",
    #       active_fg = "000000",
    #       inactive_bg = "ff78c5",
    #       inactive_fg = "1e1f28",
    #       padding_left = 6,
    #       padding_x = 0,
    #       padding_y = 5,
    #       section_top = 10,
    #       section_bottom = 15,
    #       level_shift = 8,
    #       vspace = 0,
    #       margin_y = 20,
    #       panel_width = 100
    #       ),
    layout.Floating(**layout_theme,
                      fullscreen_border_width = 1,
                      max_border_width = 1),
    #layout.Slice(**layout_theme)
]

colors = [["#1e1f28", "#1e1f28"], 
          ["#3d3f4b", "#434758"], 
          ["#ff78c5", "#ff78c5"], 
          ["#bd92f8", "#bd92f8"], 
          ["#bd92f8", "#bd92f8"], 
          ["#ff78c5", "#ff78c5"], 
          ["#e1acff", "#e1acff"], 
          ["#ecbbfb", "#ecbbfb"]] 

prompt = "{0}@{1}: ".format(os.environ["USER"], socket.gethostname())

##### DEFAULT WIDGET SETTINGS #####
widget_defaults = dict(
    font="Ubuntu Mono",
    fontsize = 13,
    padding = 2,
    background=colors[2]
)
extension_defaults = widget_defaults.copy()

def init_widgets_list():
    widgets_list = [
             widget.Sep(
                       linewidth = 0,
                       padding = 6,
                       foreground = colors[2],
                       background = colors[0]
                       ),
             widget.Image(
                        filename = "~/.config/qtile/icons/arch1.png",
                        scale = "False",
                        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myterm)},
                        padding = 10
                        ), 
             widget.Sep(
                       linewidth = 0,
                       padding = 6,
                       foreground = colors[2],
                       background = colors[0]
                       ),

             #widget.TextBox(
             #          text = '∖',
             #          background = colors[0],
             #          foreground = colors[5],
             #          padding = 4,
             #          fontsize = 30
             #          ),

             widget.GroupBox(
                       font = "Ubuntu Bold",
                       fontsize = 10,
                       margin_y = 3,
                       margin_x = 0,
                       padding_y = 5,
                       padding_x = 3,
                       borderwidth = 3,
                       active = colors[7],
                       inactive = colors[2],
                       rounded = True,
                       highlight_color = colors[1],
                       highlight_method = "block",
                       this_current_screen_border = "#545454",
                       this_screen_border = "#44475a",
                       other_current_screen_border = "#545454",
                       other_screen_border = "#44475a",
                       urgent_border = colors[0],
                       urgent_alert_method = "block",
                       foreground = colors[2],
                       background = colors[0]
                       ),
             widget.Prompt(
                       prompt = prompt,
                       font = "Ubuntu Mono",
                       padding = 10,
                       foreground = colors[3],
                       background = colors[1]
                       ),
             widget.Sep(
                       linewidth = 0,
                       padding = 20,
                       foreground = colors[2],
                       background = colors[0]
                       ),
             widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[5],
                       padding = -1,
                       fontsize = 45
                       ),
             widget.CurrentLayout(
                       foreground = colors[0],
                       background = colors[5],
                       padding = 8,
                       fontsize = 15
                       ), 
             widget.TextBox(
                       text = '',
                       background = colors[5],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),

             widget.Sep(
                       linewidth = 0,
                       padding = 20,
                       foreground = colors[2],
                       background = colors[0]
                       ),
             #widget.WindowName(
             #          foreground = colors[6],
             #          background = colors[0],
             #          padding = 0
             #           ),
             widget.TaskList(
                       foreground = colors[6],
                       background = colors[0],
                       padding = 0,
                       margin = 5,
                       border = colors[4],
                       borderwidth = 1,
                       urgent_alert_method = "text",
                       urgent_border = colors[5]
                       ),
             widget.Sep(
                       linewidth = 0,
                       padding = 6,
                       foreground = colors[0],
                       background = colors[0]
                       ),
             widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[5],
                       padding = -1,
                       fontsize = 45
                       ),
             widget.Clock(
                       foreground = colors[0],
                       background = colors[5],
                       format = "  %A, %B %d/%Y - %H:%M ",
                       mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn("yad --calendar")},
                       ),
             widget.KeyboardLayout(
                       foreground = colors[0],
                       background = colors[5],
                       configured_keyboards = ['us', 'se'],
                        padding = 10,
                       ),
             widget.TextBox(
                       text = '',
                       background = colors[5],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),

             widget.Sep(
                       linewidth = 100,
                       padding = 140,
                       foreground = colors[0],
                       background = colors[0]
                       ),
             #widget.Net(
             #         interface = "enp4s0",
             #         format = '{down} ↓↑ {up}',
             #         foreground = colors[2],
             #         background = colors[4],
             #         padding = 5
             #    ),
             widget.Chord(
                       background = colors[0],
                       foreground = colors[5],
                       padding = 1
                       ), 

             widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
             widget.TextBox(
                       text = '🖴',
                       background = colors[0],
                       foreground = colors[4],
                       padding = 1,
                       fontsize = 13
                       ),
               
             widget.DF(
                        partition = "/media/vm",
                        visible_on_warn = False,
                        foreground = colors[4],
                        background = colors[0]
                        ),
             widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
             widget.TextBox(
                       text = '★',
                       background = colors[0],
                       foreground = colors[5],
                       padding = -1,
                       ),
             widget.CPU(
                         foreground = colors[5],
                         background = colors[0],
                         padding = 8,
                         format = '{load_percent}%'
                          ),
             widget.TextBox(
                       text='',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
             # widget.TextBox(
             #          text = " ⟳",
             #          padding = 2,
             #          foreground = colors[0],
             #          background = colors[4],
             #          fontsize = 14
             #          ),
             # widget.CheckUpdates(
             #          update_interval = 1800,
             #          distro = "Arch_checkupdates",
             #          display_format = "{updates} Updates",
             #          color_have_updates = colors[0],
             #          color_no_updates = colors[0],
             #          foreground = colors[0],
             #          mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(myterm + ' -e sudo pacman -Syu')},
             #          background = colors[4]
             #          ),
             widget.TextBox(
                         text = " 🌡",
                         padding = 6,
                         foreground = colors[4],
                         background = colors[0],
                         fontsize = 11,
                         tag_sensor =  "temp1"
                            ),

             widget.ThermalSensor(
                        background = colors[0],
                        foreground = colors[4],
                        tag_sensor = "Core 0",
                        threshold = 75,
                          ),
             widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
             widget.TextBox(
                       text = " 🖬",
                       foreground = colors[5],
                       background = colors[0],
                       padding = 0,
                       fontsize = 14
                       ),
             widget.Memory(
                       foreground = colors[5],
                       background = colors[0],
                       mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(sysmon)},
                       padding = 5
                       ),
             widget.TextBox(
                       text='',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
             widget.TextBox(
                       text = "♥  karl-x99 ",
                       padding = 0,
                       foreground = colors[4],
                       background = colors[0],
                       fontsize = 12
                       ),
             #widget.BitcoinTicker(
             #        foreground = colors[2],
             #        background = colors[4],
             #        padding = 5
             #      ),
             widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
             widget.TextBox(
                      text = "♫  Vol:",
                      foreground = colors[5],
                      background = colors[0],
                      padding = 0,
                      mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn("pavucontrol")}
                       ),
              widget.Volume(
                       foreground = colors[5],
                       background = colors[0],
                       padding = 5
                       ),
              widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
             # widget.CurrentLayoutIcon(
             #          custom_icon_paths = [os.path.expanduser("~/.config/qtile/icons")],
             #          foreground = colors[0],
             #          background = colors[0],
             #          padding = 0,
             #          scale = 0.7
             #          ),
            widget.TextBox(
                       text = '',
                       background = colors[0],
                       foreground = colors[0],
                       padding = -1,
                       fontsize = 45
                       ),
            
            widget.TextBox(
                       text = '',
                      background = colors[0],
                       foreground = colors[5],
                       padding = 4,
                       fontsize = 15
                       ),
            widget.Sep(
                       linewidth = 0,
                       padding = 6,
                       foreground = colors[2],
                       background = colors[0]
                       ),
            widget.Systray(
                      background = colors[0],
                      padding = 5
                      ),
             widget.Sep(
                       linewidth = 0,
                       padding = 6,
                       foreground = colors[2],
                       background = colors[0]
                       ),


            
              ]


    return widgets_list

def init_widgets_screen2():
    widgets_screen2 = init_widgets_list()
    del widgets_screen2[38:39]               # Slicing removes unwanted widgets (systray) on Monitors 2,3
    return widgets_screen2

def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    return widgets_screen1                 # Monitor 1 will display all widgets in widgets_list

def init_screens():
    return [Screen(top=bar.Bar(widgets=init_widgets_screen1(), opacity=1.0, size=23, margin=3 )),
            Screen(top=bar.Bar(widgets=init_widgets_screen2(), opacity=1.0, size=23, margin=3)),
            Screen(top=bar.Bar(widgets=init_widgets_screen1(), opacity=1.0, size=23, margin=3))]

if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    widgets_screen2 = init_widgets_screen2()

def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)

def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)

def window_to_previous_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group)

def window_to_next_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group)

def switch_screens(qtile):
    i = qtile.screens.index(qtile.current_screen)
    group = qtile.screens[i - 1].group
    qtile.current_screen.set_group(group)

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    # default_float_rules include: utility, notification, toolbar, splash, dialog,
    # file_progress, confirm, download and error.
    *layout.Floating.default_float_rules,
    Match(title='Confirmation'),  # tastyworks exit box
    Match(title='Qalculate!'),  # qalculate-gtk
    Match(wm_class='kdenlive'),  # kdenlive
    Match(wm_class='gimp-2.10'),  # gimp
    Match(wm_class='pinentry-gtk-2'),  # GPG key password entry
    Match(wm_class='yad'),
    Match(wm_class='bitwarden'),
    Match(wm_class='Cinelerra'),
    Match(wm_class='Gpick'),
    Match(wm_class='resolve'),
    Match(wm_class='Olive'),
    Match(wm_class='lxtask'),
    Match(wm_class='pavucontrol'),
    Match(wm_class='sxiv'),
    Match(wm_class='timeshift-gtk'),
    Match(wm_class=virtman),
    Match(wm_class="shotcut")
])
auto_fullscreen = True
focus_on_window_activation = "smart"





@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])
   



# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

