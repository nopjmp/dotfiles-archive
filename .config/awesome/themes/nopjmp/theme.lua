 -- read program output
 function pread(cmd)
     if cmd and cmd ~= "" then
         local f, err = io.popen(cmd, 'r')
         if f then
             local s = f:read("*all")
             f:close()
             return s
         else
             return err
         end
     end
 end

 theme = {}

 local home = os.getenv("HOME")
 local config = home .. "/.config/awesome"
 local icon_dir = config .. "/themes/nopjmp/icons/"
 local layout_icon_dir = config .. "/icons/anrxc/layouts-small/"
 theme.font = "Termsyn.Icons 10"
 
 local black    = "#101010"
 local red      = "#960050"
 local green    = "#66aa11"
 local yellow   = "#c47f2c"
 local blue     = "#30309b"
 local magenta  = "#7e40a5"
 local cyan     = "#3579a8"
 local white    = "#9999aa"
 local lblack   = "#303030"
 local lred     = "#ff0090"
 local lgreen   = "#80ff00"
 local lyellow  = "#ffba68"
 local lblue    = "#5f5fee"
 local lmagenta = "#bb88dd" 
 local lcyan    = "#4eb4fa"
 local lwhite   = "#d0d0d0"
 local background = black
 local foreground = lwhite

 -- net widget
 theme.net_up = lred
 theme.net_down = lgreen

 theme.bg_light = lblack

 theme.bg_normal = background
 theme.bg_focus = background
 theme.bg_urgent = background
 theme.bg_minimize = background
 theme.bg_systray = background

 theme.fg_normal = white
 theme.fg_focus = lblue
 theme.fg_urgent = lmagenta
 theme.fg_minimize = lblack

 theme.fg_delimiter = lblue
 theme.fg_modebox = lmagenta


 theme.fg_dmenu = blue
 theme.fg_dmenu_foc = lblue
 theme.bg_dmenu = background
 theme.bg_dmenu_foc = background
                        
 theme.border_width = 1
 theme.border_normal = black
 theme.border_light = lwhite
 theme.border_marked = lblue

 theme.taglist_fg_urgent = theme.fg_urgent
 theme.taglist_fg_focus = theme.fg_focus

 theme.menu_submenu_icon = config .. "/themes/nopjmp/submenu.png"
 theme.menu_height = "15"
 theme.menu_width = "80"

 theme.wallpaper = { }

 theme.tasklist_fg_focus = theme.fg_focus
 theme.tasklist_fg_occupied = white
 
 -- Icon Section
 theme.icon_ac = icon_dir .. "ac.png"     
 theme.icon_arch = icon_dir .. "arch.png"
 theme.icon_bat_empty = icon_dir .. "bat_empty.png"
 theme.icon_bat_low = icon_dir .. "bat_low.png"
 theme.icon_bat_full = icon_dir .. "bat_full.png"
 theme.icon_bluetooth = icon_dir .. "bluetooth.png"
 theme.icon_clock = icon_dir .. "clock.png"
 theme.icon_cpu = icon_dir .. "cpu.png"
 theme.icon_fan = icon_dir .. "fs.png"
 theme.icon_mail = icon_dir .. "mail.png"
 theme.icon_mem = icon_dir .. "mem.png"
 theme.icon_net_down = icon_dir .. "net_down_01.png"
 theme.icon_net_up = icon_dir .. "net_up_01.png"
 theme.icon_net_wired = icon_dir .. "net_wired.png"
 theme.icon_pacman = icon_dir .. "pacman.png"
 theme.icon_note = icon_dir .. "note.png"
 theme.icon_speaker_full= icon_dir .. "spkr_full.png"
 theme.icon_speaker_low = icon_dir .. "spkr_low.png"
 theme.icon_temp = icon_dir .. "temp.png"
 theme.icon_net_wifi = icon_dir .. "wifi_01.png"

 ---- Layout Icon
-- theme.layout_fairh      = ""
-- theme.layout_fairv      = ""
-- theme.layout_floating   = "" 
-- theme.layout_max        = ""
-- theme.layout_spiral     = ""
-- theme.layout_tilebottom = ""
-- theme.layout_tileleft   = ""
-- theme.layout_tile       = ""
-- theme.layout_tiletop    = "t"
-- theme.layout_fullscreen = "f"
-- theme.layout_dwindle    = "d"
-- theme.layout_magnifier  = "m"
 
 -- Layout Icon as Images
 theme.layout_fairh      = layout_icon_dir .. "fairh.png"
 theme.layout_fairv      = layout_icon_dir .. "fairv.png"
 theme.layout_floating   = layout_icon_dir .. "floating.png"
 theme.layout_max        = layout_icon_dir .. "max.png"
 theme.layout_spiral     = layout_icon_dir .. "spiral.png"
 theme.layout_tilebottom = layout_icon_dir .. "tilebottom.png"
 theme.layout_tileleft   = layout_icon_dir .. "tileleft.png"
 theme.layout_tile       = layout_icon_dir .. "tile.png"
 theme.layout_tiletop    = layout_icon_dir .. "tiletop.png"
 theme.layout_fullscreen = layout_icon_dir .. "fullscreen.png"
 theme.layout_dwindle    = layout_icon_dir .. "dwindle.png"
 theme.layout_magnifier  = layout_icon_dir .. "magnifier.png"
 
 -- Invisible awesome icon
 theme.awesome_icon = config .. "/icons/awesome16.png"

 -- Invisible taglist squares
 theme.taglist_squares_sel = config .. "/themes/nopjmp/taglist/squarefw.png"
 theme.taglist_squares_unsel = config .. "/themes/nopjmp/taglist/squarew.png"


 theme.icon_theme = "Faenza"
 return theme

