 -- Thanks to neeee on github for the awesome rc.lua and font ;)
 -- {{{ Libraries
 -- Standard awesome library
 local awful = require("awful")
 require("awful.autofocus")

 local beautiful = require("beautiful")
 local naughty = require("naughty")
 local vicious = require("vicious")
 local wibox = require("wibox")
 local luz = require("luz")
 -- }}}
 -- {{{ Error handling
 -- Handle runtime errors after startup
 do
     local in_error = false
     awesome.connect_signal("debug::error", function (err)
         -- Make sure we don't go into an endless error loop
         if in_error then return end
         in_error = true
         naughty.notify({
             preset = naughty.config.presets.critical,
             title = "Opps, an error happened!",
             text = err
         })
         in_error = false
     end)
 end
 -- }}}
 -- {{{ Awesome hacks
 -- Disable startup-notification globally
 local oldspawn = awful.util.spawn
 awful.util.spawn = function(s) oldspawn(s, false) end
 -- }}}
 -- {{{ Variable definitions
 local home = os.getenv("HOME")
 beautiful.init( home .. "/.config/awesome/themes/nopjmp/theme.lua" )

 local modkey = "Mod4"
 local altkey = "Mod1"

 -- Standard programs
 local browser = os.getenv("BROWSER") or "firefox"
 local terminal = "termite"
 local editor = terminal .. " -e vim "
 local mail = terminal .. " -e mutt "
 local filemanager = terminal .. " -e ranger "

 -- Layouts
 local layouts = {
     awful.layout.suit.floating,
     awful.layout.suit.tile,
     awful.layout.suit.tile.left,
     awful.layout.suit.fair,
     awful.layout.suit.horizontal
 }

 -- Tags
 local tags = {}
 local tag_symbols = { "web", "code", "im", "mail", "null" }
 local tag_layouts = { layouts[1], layouts[2], layouts[1], layouts[2], layouts[1] }
 local tag_num = 5
 for s = 1, screen.count() do
     tags[s] = awful = awful.tag(tag_symbols, s, tag_layouts)
 end
 -- {{{ Menus
 mymainmenu = awful.menu({items = {
                { "Terminal", terminal },
                { "Restart", awesome.restart }
            }})
 -- }}}
 -- {{{ Functions
 -- Colours
 function paint(s, fg)
     return "<span foreground='" .. fg .. "'>" .. s .. "</span>"
 end

 -- Raise client
 function raise(c) c.focus:raise() end

 -- Test if client is floating
 function is_floating(c)
     local layout = awful.layout.get(c.screen)
     return awful.layout.getname(layout) == "floating" or
        awful.client.floating.get(c)
 end

 -- Integrate dmenu with beautiful
 function beautiful_dmenu(cmd, text, ret)
     local run = cmd .. 
        " -i -b -p '" .. text .. " '" ..
        "  -nb '" .. beautiful.bg_dmenu ..
        "' -nf '" .. beautiful.fg_dmenu ..
        "' -sb '" .. beautiful.bg_dmenu_foc ..
        "' -sf '" .. beautiful.fg_dmenu_foc ..
        "' -fn '" .. beautiful.font .. "'"

     -- Only return if passed true (for functions that need the output)
     if ret then
         return awful.util.pread(run)
     end

     os.execute(run)
 end
 -- }}}
 -- {{{ Widgets
 -- CPU
 cpuwidget = wibox.widget.textbox()
 vicious.register(cpuwidget, vicious.widgets.cpu,
    function (widget, args)
        if args[1] == 100 then
            return " " .. paint("99", theme.taglist_fg_urget) .. "%"
        end
        return string.format(" ⭥ %02d%%", args[1])
    end, 5)
 
 -- Clock
 datewidget = wibox.widget.textbox()
 vicious.register(datewidget, vicious.widgets.date, " ⭧ %R", 60)
 do
     local timenot
     function showtime()
         if timenotification ~=nil then naughty.destory(timenot) end
         timenot = naughty.notify({
                        text = os.date("%A %B %d %Y (%F)"),
                        timeout = 5,
                    })
     end
 end
 datewidget:buttons(awful.button({ }, 1, showtime))
 
 -- RAM
 memwidget = wibox.widget.textbox()
 vicious.register(memwidget, vicious.widgets.mem, " ⭦ $2MiB", 5)

 -- Launcher
 mylauncher = awful.widget.launcher({
            image = beautiful.awesome_icon,
            menu = mymainmenu
        })
 -- Modebox widget
 modebox = wibox.widget.textbox()
 modebox.set_text(modebox, "")

 -- Spacer
 spacer = wibox.widget.textbox()
 spacer.set_text(spacer, " ")

 -- Systray (with workaround for toggling)
 systray = wibox.widget.systray()
 stupid_bug = drawin({})
 systray_container = wibox.layout.margin(systray)
 awesome.systray(stupid_bug, 0, 0, 10, true, "#000000")
 systray_container:set_widget(nil)

 -- }}}
 -- {{{ Wibox
 -- Create a wibox for each screen and add it
 mywibox = {}
 mylayoutbox = {}
 mytaglist = {}
 mytaglist.buttons = awful.util.table.join(
        awful.button({ }, 1, awful.tag.viewonly),
        awful.button({ modkey }, 1, awful.client.movetotag),
        awful.button({ }, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, awful.client.toggletag),
        awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
        awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
 )

 mytasklist = {}
 mytasklist.buttons = awful.util.table.join(
        awful.button({ }, 1,
            function (c)
                if c == client.focus then
                    c.minimized = true
                else
                    if not c:isvisible() then
                        awful.tag.viewonly(c:tags()[1])
                    end
                    -- This will also un-minimize
                    -- the client, if needed
                    client.focus = c
                    c:raise()
                end
            end),
       awful.button({ }, 3,
            function ()
                if instance then
                    instance:hide()
                    instance = nil
                else
                    instance = awful.menu.clients({ width = 250 })
                end
            end),
       awful.button({ }, 4,
            function ()
                awful.client.focus.byidx(1)
                if client.focus then client.focus:raise() end
            end),
       awful.button({ }, 5,
            function ()
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end))
 for s = 1, screen.count() do
     -- Layoutbox
     mylayoutbox[s] = luz.widget.layoutbox(s)
     mylayoutbox:buttons(awful.util.table.join(
            awful.b
