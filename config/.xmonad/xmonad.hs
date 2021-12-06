  -- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Minimize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.Minimize

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Minimize
import XMonad.Layout.PerWorkspace
 

 -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Font

myFont :: String
myFont = "xft:Ubuntu:regular:size=10:antialias=false:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask        -- Sets modkey to super/windows key

myTmux :: String
myTmux = "kitty /usr/bin/myscripts/create_tmux_session.sh"    -- Sets default tmux script
myTerminal :: String
myTerminal = "kitty"    -- Sets default terminal

myBrowser :: String
myBrowser = "qutebrowser "  -- Sets qutebrowser as browser


myEditor :: String
myEditor = "neovide"  -- Sets neovide as myeditor
-- myEditor = myTerminal ++ " -e vim "    -- Sets vim as editor

myFilemanager :: String
myFilemanager = "pcmanfm /home/karl/Pictures"


myBorderWidth :: Dimension
myBorderWidth = 2           -- Sets border width for windows

myNormColor :: String
myNormColor   = "#282c34"   -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#ff78c5"   -- Border color of focused windows

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "lxsession &"
    spawnOnce "picom -b --config  $HOME/.config/qtile/picom.conf"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"
    spawnOnce "conky -c /home/karl/.config/qtile/system-overview"
    spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34  --height 22 &"
    spawnOnce "steam &"
    spawnOnce "lutris &"
    spawnOnce "xfce4-screensaver &"
    spawnOnce "/home/karl/.xmonad/layout_rule.sh &"
    spawnOnce "/home/karl/.xmonad/cursor.sh &"
    -- uncomment to restore last saved wallpaper
    -- spawnOnce "xargs xwallpaper --stretch < ~/.xwallpaper"
    --uncomment to set a random wallpaper on login
    -- spawnOnce "find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch"

    spawnOnce "~/.fehbg &"  -- set last saved feh wallpaper

    -- spawnOnce "feh --randomize --bg-fill ~/wallpapers/*"  -- feh set random wallpaper
    -- spawnOnce "nitrogen --restore &"   -- if you prefer nitrogen to feh
    setWMName "LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x2c,0x34) -- lowest inactive bg
                  (0x28,0x2c,0x34) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myAppGrid = [ ("Audacity", "audacity")
                 , ("Firefox", "firefox")
                 , ("Gimp", "gimp")
                 , ("Kdenlive", "kdenlive")
                 , ("LibreOffice Impress", "loimpress")
                 , ("LibreOffice Writer", "lowriter")
                 , ("OBS", "obs")
                 , ("PCManFM", "pcmanfm")
                 ]

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -t mocp -e mocp"
    findMocp   = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w 
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)

spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
--wideAccordion  = renamed [Replace "wideAccordion"]
--           $ Mirror Accordion
perWorkspace  = renamed [Replace "perWorkspace"]

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#bd92f8"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#bd92f8"
                 , inactiveBorderColor = "#1e1f28"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1e1f28"
    , swn_color             = "#ff78c5"
    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats 
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout 
             where
               myDefaultLayout =     



                   withBorder myBorderWidth threeCol
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid 
                                 ||| spirals
                                 ||| tall
                                 ||| threeRow
                                 ||| tallAccordion
                   --              ||| wideAccordion
             
-- myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
myWorkspaces = [" www ", " dev ", " sys ", " games ", " kvm ", " chat ", " mus ", " vid ", " gfx "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"         --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "error"           --> doFloat
     , className =? "Gimp-2.10"            --> doCenterFloat
     , className =? "kdenlive"            --> doCenterFloat
     , className =? "notification"    --> doFloat
     , className =? "pinentry-gtk-2"  --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , className =? "Yad"             --> doCenterFloat
     , className =? "Display"             --> doCenterFloat
     , className =? "Pcmanfm"             --> doCenterFloat
     , className =? "Lxtask"             --> doCenterFloat
     , title =? "Oracle VM VirtualBox Manager"  --> doFloat
     , title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 1 )
     , title =? "Spotify"     --> doShift ( myWorkspaces !! 6 )
     , className =? "brave-nightly"   --> doShift ( myWorkspaces !! 0 )
     , className =? "Virt-manager"   --> doShift ( myWorkspaces !! 4 )
     , className =? "qutebrowser"     --> doShift ( myWorkspaces !! 0 )
     , className =? "mpv"             --> doCenterFloat 
     , className =? "Gimp-2.10"            --> doShift ( myWorkspaces !! 8 )
     , className =? "Steam"            --> doShift ( myWorkspaces !! 3 )
     , className =? "heroic"            --> doShift ( myWorkspaces !! 3 )
     , className =? "Lutris"            --> doShift ( myWorkspaces !! 3 )
     , className =? "discord"            --> doShift ( myWorkspaces !! 5 )
     , className =? "obs"            --> doShift ( myWorkspaces !! 7 )
     , className =? "Spotfiy"            --> doShift ( myWorkspaces !! 6 )
     , className =? "steam_proton"            --> doShift ( myWorkspaces !! 3 )
     , className =? "kdenlive"            --> doShift ( myWorkspaces !! 8 )
     , className =? "Lxappearance"      --> doShift ( myWorkspaces !! 2 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
     ] <+> namedScratchpadManageHook myScratchPads

-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
    -- KB_GROUP Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")  -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")    -- Restarts xmonad
        , ("M-S-q", io exitSuccess)              -- Quits xmonad
        , ("M-S-/", spawn "~/.xmonad/xmonad_keys.sh")
        , ("M-y", spawn "~/scripts/activated/kitty_keys.sh")

    -- KB_GROUP Run Prompt
        , ("M-r", spawn  "rofi -show drun  -display-drun \"Run : \" -drun-display-format \"{name}\"") -- Rofi

    -- KB_GROUP Other Dmenu Prompts
    -- In Xmonad and many tiling window managers, M-p is the default keybinding to
    -- launch dmenu_run, so I've decided to use M-p plus KEY for these dmenu scripts.
        , ("M-p e", spawn "/home/karl/.dmenu/dmenueditconfig" ) -- edit config files
        , ("M-p m", spawn "/home/karl/.dmenu/mount_harddrives" ) -- mount some drives
        , ("M-p k", spawn "/home/karl/.dmenu/dmenukill" )   -- kill processes
        , ("M-p r", spawn "sudo /home/karl/.dmenu/dmenueditconfig" ) -- edit root config files
        , ("M-p w", spawn "/home/karl/.dmenu/set_wallpaper" ) -- set wallpaper
        , ("M-p p", spawn "/home/karl/.dmenu/dmenuapp" ) -- open a program
        , ("M-p a", spawn "/home/karl/.dmenu/audioset" ) -- change audio output
        , ("M-p o", spawn "/home/karl/.dmenu/openweb" ) -- open quickmarks in qutebrowser
        , ("M-p t", spawn "/home/karl/.dmenu/kittychangetheme" ) -- change theme for kitty terminal
        , ("M-p l", spawn "/home/karl/.dmenu/dmenulayout" ) --  change keyboard layout
        , ("M-p v", spawn "/home/karl/.dmenu/nordvpn" ) -- choose vpn server to connect to
        , ("M-p s", spawn "/home/karl/.dmenu/search" ) -- search various search engines
        , ("M-p f", spawn "/home/karl/.dmenu/display_font" ) -- show the fonts installed 
        , ("M-p g", spawn "/home/karl/.dmenu/fullscreen_website" ) -- open a website in fullscreen mode

    -- KB_GROUP Useful programs to have a keybinding for launch
        , ("M-<Return>", spawn (myTmux))
        , ("C-M1-t", spawn (myTerminal))
        , ("M-M1-b", spawn ("sudo timeshift-gtk"))
        , ("M-b", spawn (myBrowser ))
        , ("M-M1-h", spawn (myTerminal ++ " -e htop"))
        , ("M-M1-e", spawn (myTerminal ++ " -e vim"))
        , ("M-S-w", spawn ("brave" ))
        , ("M-S-v", spawn ("virt-manager" ))
        , ("M-s", spawn ("flameshot gui" ))
        , ("M-i", spawn ("lxappearance" ))
        , ("M-o", spawn ("obs" ))
        , ("M-S-e", spawn (myTerminal ++ " -e vifm" ))
        , ("M-S-y", spawn (myEditor ))
        , ("M-C-;", spawn ("xfce4-screensaver-command -l" ))
        , ("M-S-<Return>", spawn (myFilemanager ))

    -- KB_GROUP Kill windows
        , ("M-q", kill1)     -- Kill the currently focused client
        , ("M-S-a", killAll)   -- Kill all windows on current workspace

    -- KB_GROUP Workspaces
        , ("M-w", nextScreen)  -- Switch focus to next monitor
        , ("M-e", prevScreen)  -- Switch focus to prev monitor
        , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
        , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws

    -- KB_GROUP Floating windows
        , ("M-f", sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile

    -- KB_GROUP Increase/decrease spacing (gaps)
        , ("C-M1-j", decWindowSpacing 4)         -- Decrease window spacing
        , ("C-M1-k", incWindowSpacing 4)         -- Increase window spacing
        , ("C-M1-h", decScreenSpacing 4)         -- Decrease screen spacing
        , ("C-M1-l", incScreenSpacing 4)         -- Increase screen spacing

    -- KB_GROUP Grid Select (CTR-g followed by a key)
        , ("C-g g", spawnSelected' myAppGrid)                 -- grid select favorite apps
        , ("C-g t", goToSelected $ mygridConfig myColorizer)  -- goto selected window
        , ("C-g b", bringSelected $ mygridConfig myColorizer) -- bring selected window

    -- KB_GROUP Windows navigation
        , ("M-m", windows W.focusMaster)  -- Move focus to the master window
        , ("M-j", windows W.focusDown)    -- Move focus to the next window
        , ("M-k", windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
        , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- KB_GROUP Layouts
        , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
       , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase # of clients master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease # of clients master pane
        , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
        , ("M-C-<Down>", decreaseLimit)                 -- Decrease # of windows

    -- KB_GROUP Window resizing
        , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-k", sendMessage MirrorExpand)          -- Expand vert window width

    --    , ("M-n", minimizeWindow :: Window -> X ())          -- Expand vert window width
    --    , ("M-S-m", withLastMinimized maximizeWindowAndFocus)          -- Expand vert window width
     
    -- KB_GROUP Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        , ("M-C-h", sendMessage $ pullGroup L)
        , ("M-C-l", sendMessage $ pullGroup R)
        , ("M-C-k", sendMessage $ pullGroup U)
        , ("M-C-j", sendMessage $ pullGroup D)
        , ("M-C-m", withFocused (sendMessage . MergeAll))
        -- , ("M-C-u", withFocused (sendMessage . UnMerge))
        , ("M-C-/", withFocused (sendMessage . UnMergeAll))
        , ("M-C-.", onGroup W.focusUp')    -- Switch focus to next tab
        , ("M-C-,", onGroup W.focusDown')  -- Switch focus to prev tab

    -- KB_GROUP Scratchpads
    -- Toggle show/hide these programs.  They run on a hidden workspace.
    -- When you toggle them to show, it brings them to your current workspace.
    -- Toggle them to hide and it sends them back to hidden workspace (NSP).
        , ("C-s t", namedScratchpadAction myScratchPads "terminal")
        , ("C-s m", namedScratchpadAction myScratchPads "mocp")
        , ("C-s c", namedScratchpadAction myScratchPads "calculator")

    -- KB_GROUP Set wallpaper
    -- Set wallpaper with either 'xwallwaper'. Type 'SUPER+F1' to launch sxiv in the
    -- wallpapers directory; then in sxiv, type 'C-x x' to set the wallpaper that you
    -- choose.  Or, type 'SUPER+F2' to set a random wallpaper.
        , ("C-M1-w", spawn "sxiv -r -q -t -o /var/pictures/backgrounds/*")
        , ("C-M1-r", spawn "/usr/bin/myscripts/set_random_bg")

    -- KB_GROUP Controls for mocp music player (SUPER-u followed by a key)
        , ("M-u p", spawn "/usr/bin/myscripts/mediaplay")
        , ("M-u l", spawn "/usr/bin/myscripts/medianext")
        , ("M-u h", spawn "/usr/bin/myscripts/mediaprev")


    -- KB_GROUP Multimedia Keys
        , ("<XF86AudioPlay>", spawn "/usr/bin/myscripts/mediaplay")
        , ("<XF86AudioPrev>", spawn "/usr/bin/myscripts/mediaprev")
        , ("<XF86AudioNext>", spawn "/usr/bin/myscripts/medianext")
        , ("<XF86AudioMute>", spawn "amixer set Master toggle")
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<XF86HomePage>", spawn "qutebrowser https://www.youtube.com/c/DistroTube")
        , ("<XF86Search>", spawn "dm-websearch")
        , ("<XF86Mail>", runOrRaise "thunderbird" (resource =? "thunderbird"))
        , ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
        , ("<XF86Eject>", spawn "toggleeject")
        , ("<Print>", spawn "dm-maim")
        ]
    -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))
-- END_KEYS

main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
    -- the xmonad, ya know...what the WM is named after!
    xmonad $ ewmh def
        { manageHook         = myManageHook <+> manageDocks
        , handleEventHook    = docksEventHook
                               -- Uncomment this line to enable fullscreen support on things like YouTube/Netflix.
                               -- This works perfect on SINGLE monitor systems. On multi-monitor systems,
                               -- it adds a border around the window if screen does not have focus. So, my solution
                               -- is to use a keybinding to toggle fullscreen noborders instead.  (M-<Space>)
                               -- <+> fullscreenEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
 --       , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , layoutHook         =  myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
              -- the following variables beginning with 'pp' are settings for xmobar.
              { ppOutput = \x -> hPutStrLn xmproc0 x                          -- xmobar on monitor 1
                              >> hPutStrLn xmproc1 x                          -- xmobar on monitor 2
                                                        
              , ppCurrent = xmobarColor "#bd92f8" "" . wrap "<box type=Bottom width=2 mb=2 color=#ff78c5>" "</box>"         -- Current workspace
              , ppVisible = xmobarColor "#bd92f8" "" . clickable              -- Visible but not current workspace
              , ppHidden = xmobarColor "#ff78c5" "" . wrap "<box type=Top width=2 mt=2 color=#ff78c5>" "</box>" . clickable -- Hidden workspaces
              , ppHiddenNoWindows = xmobarColor "#ff78c5" ""  . clickable     -- Hidden workspaces (no windows)
              , ppTitle = xmobarColor "#bd92f8" "" . shorten 60               -- Title of active window
              , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"                    -- Separator character
              , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
              , ppExtras  = [windowCount]                                     -- # of windows current workspace
              , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
              }
        } `additionalKeysP` myKeys
