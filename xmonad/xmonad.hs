-- IMPORTS 

import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageDocks
import XMonad.Layout.IndependentScreens
-- import XMonad.Hooks.StatusBar

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified XMonad.Layout.Decoration as XMonad.Layout.LayoutModifier
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, xmobarPP, xmobarColor, PP (ppCurrent, ppVisible, ppHidden, ppOutput, ppHiddenNoWindows, ppTitle, ppSep, ppUrgent, ppExtras, ppOrder, ppWsSep, ppVisibleNoWindows), wrap, shorten)
import XMonad.Util.NamedScratchpad (namedScratchpadFilterOutWorkspacePP)
import GHC.IO.Handle
import Data.Maybe
import XMonad.Actions.CycleWS

-- Colors
grey1, grey2, grey3, grey4, cyan, orange :: String
grey1  = "#2B2E37"
grey2  = "#555E70"
grey3  = "#697180"
grey4  = "#8691A8"
cyan   = "#8BABF0"
orange = "#C45500"

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal :: String
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth :: Dimension
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask :: KeyMask
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces :: [String]
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor :: String
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor :: String
myFocusedBorderColor = "#01caff"

------------------------------------------------------------------------
-- Logic responsible to isolate workspaces on xmobar
--
currentScreen :: X ScreenId
currentScreen = gets (W.screen . W.current . windowset)

isOnScreen :: ScreenId -> WindowSpace -> Bool
isOnScreen s ws = s == unmarshallS (W.tag ws)

workspaceOnCurrentScreen :: WSType
workspaceOnCurrentScreen = WSIs $ do
  s <- currentScreen
  return $ \x -> W.tag x /= "NSP" && isOnScreen s x

-- myXmobarPP :: ScreenId -> PP
-- myXmobarPP s  = filterOutWsPP [scratchpadWorkspaceTag] . marshallPP s $ def
--   { ppSep = ""
--   , ppWsSep = ""
--   , ppCurrent = xmobarColor cyan "" . clickable wsIconFull
--   , ppVisible = xmobarColor grey4 "" . clickable wsIconFull
--   , ppVisibleNoWindows = Just (xmobarColor grey4 "" . clickable wsIconFull)
--   , ppHidden = xmobarColor grey2 "" . clickable wsIconHidden
--   , ppHiddenNoWindows = xmobarColor grey2 "" . clickable wsIconEmpty
--   , ppUrgent = xmobarColor orange "" . clickable wsIconFull
--   , ppOrder = \(ws : _ : _ : extras) -> ws : extras
--   , ppExtras  = [ wrapL (actionPrefix ++ "n" ++ actionButton ++ "1>") actionSuffix
--                 $ wrapL (actionPrefix ++ "q" ++ actionButton ++ "2>") actionSuffix
--                 $ wrapL (actionPrefix ++ "Left" ++ actionButton ++ "4>") actionSuffix
--                 $ wrapL (actionPrefix ++ "Right" ++ actionButton ++ "5>") actionSuffix
--                 $ wrapL "    " "    " $ layoutColorIsActive s (logLayoutOnScreen s)
--                 , wrapL (actionPrefix ++ "q" ++ actionButton ++ "2>") actionSuffix
--                 $  titleColorIsActive s (shortenL 81 $ logTitleOnScreen s)
--                 ]
--   }
--   where
--     wsIconFull   = "  <fn=2>\xf111</fn>   "
--     wsIconHidden = "  <fn=2>\xf111</fn>   "
--     wsIconEmpty  = "  <fn=2>\xf10c</fn>   "
--     titleColorIsActive n l = do
--       c <- withWindowSet $ return . W.screen . W.current
--       if n == c then xmobarColorL cyan "" l else xmobarColorL grey3 "" l
--     layoutColorIsActive n l = do
--       c <- withWindowSet $ return . W.screen . W.current
--       if n == c then wrapL "<icon=" "_selected.xpm/>" l else wrapL "<icon=" ".xpm/>" l

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@XConfig {XMonad.modMask = modm} = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch flameshot 
    , ((modm,               xK_Print), spawn "flameshot gui")

    -- launch dmenu
    , ((modm,               xK_d     ), spawn "rofi -show drun")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_m     ), spawn "pactl -- set-source-mute 2 toggle")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io exitSuccess)

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ onCurrentScreen f i)
        | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings :: XConfig l -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings XConfig {XMonad.modMask = modm} = M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster)

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout :: XMonad.Layout.LayoutModifier.ModifiedLayout Spacing (XMonad.Layout.LayoutModifier.ModifiedLayout AvoidStruts (Choose Tall Full)) a
myLayout = spacingRaw False (Border 10 10 10 10) True (Border 10 10 10 10) True $
  avoidStruts (tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook :: Query (Endo WindowSet)
myManageHook = composeAll
    [ className =? "MPlayer"          --> doFloat
    , className =? "Gimp"             --> doFloat
    , className =? "Gnome-calculator" --> doFloat
    , resource  =? "desktop_window"   --> doIgnore
    , resource  =? "kdesktop"         --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook :: Event -> X All
myEventHook = mempty

myLogHook :: X ()
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook = return ()
myStartupHook :: X ()
myStartupHook = do
  spawnOnce "setxkbmap us -option compose:ralt"
  spawnOnce "nitrogen --restore &"
  spawnOnce "picom &"
  spawnOnce "exec /usr/bin/trayer --edge top --align right --margin 10 --widthtype request --height 30 --transparent true --alpha 0 --tint 0x292d3e --iconspacing 11"
  -- spawnOnce "xrandr --output DVI-D-0 --off --output DP-0 --primary --mode 3840x2160 --pos 0x1080 --rotate normal --output DP-1 --off --output HDMI-0 --mode 1920x1080 --pos 960x0 --rotate normal --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-5 --off"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main :: IO ()
main = do
  xmproc0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc0"
  xmproc1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc1"

  xmonad $ docks $ def {
    -- simple stuff
      terminal           = myTerminal
    , focusFollowsMouse  = myFocusFollowsMouse
    , clickJustFocuses   = myClickJustFocuses
    , borderWidth        = myBorderWidth
    , modMask            = myModMask
    , workspaces         = withScreens 2 myWorkspaces
    , normalBorderColor  = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor

  -- key bindings
    , keys               = myKeys
    , mouseBindings      = myMouseBindings

  -- hooks, layouts
    , layoutHook         = myLayout
    , manageHook         = myManageHook
    , handleEventHook    = myEventHook
    -- , logHook = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
    --     -- XMOBAR SETTINGS
    --     { ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x

    --     , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]" -- Current workspace

    --     , ppVisible = xmobarColor "#98be65" "" -- Visible but not current workspace

    --     , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" -- Hidden workspace

    --     , ppHiddenNoWindows = xmobarColor "#c792ea" "" -- Hidden workspace

    --     , ppTitle = xmobarColor "#b3afc2" "" . shorten 60 -- Title of active window

    --     , ppSep = "<fc=#666666> | </fc>" -- Separators

    --     , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!" -- Urgent workspace

    --     , ppOrder = \(ws:l:t:ex) -> [ws]
    --     },
      , logHook = myLogHook
      , startupHook = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
