-- {{{ Libraries
-- Standard awesome library
local awful = require("awful")
require("awful.autofocus")

local beautiful = require("beautiful")
local naughty   = require("naughty")
local vicious   = require("vicious")
local wibox     = require("wibox")
local luz       = require("luz")
local thinkpad  = require("thinkpad")
local gears     = require("gears")
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
			title = "Oops, an error happened!",
			text = err
		})
		in_error = false
	end)
end
-- }}}
-- {{{ Variable definitions
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/nopjmp/theme.lua")
gears.wallpaper.maximized( os.getenv("HOME") .. "/.wallpaper", s, true)

local modkey  = "Mod4"

-- Standard programs
local browser    = os.getenv("BROWSER") or "firefox"
local terminal   = "urxvtc"
local editor     = terminal .. " -e vim "
local tasks      = terminal .. " -e htop "
local files      = terminal .. " -e ranger "
local irc        = terminal .. " -e irssi "

-- Disable startup-notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s) oldspawn(s, false) end

-- Layouts
local layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal
}

-- Tags
local tag_num = 5
local tags = {}
local tag_symbols = { "web", "code", "im", "mail", "null" }

for s = 1, screen.count() do
	local float = layouts[1]
	tags[s] = awful.tag(tag_symbols, s, float)
end

-- Abbrevs
function focbydir(dir)
	awful.client.focus.global_bydirection(dir)
	raise(client)
end
local swpbydir = awful.client.swap.global_bydirection
-- }}}
-- {{{ Menus
mymainmenu = awful.menu({items = {
    { "Browser" , browser         },
    { "Irc"     , irc             },
    { "Term"    , terminal        },
		{ "Restart" , awesome.restart },
    { "Quit"    , awesome.quit    }
	}})
-- }}}
-- {{{ Functions
-- Colorize stuff
function paint(s, fg)
	return "<span foreground='"..fg.."'>"..s.."</span>"
end

-- Raise client
function raise(c) c.focus:raise() end

-- Test if client is floating
function floats(c)
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

function dmenu_raise()
	local clients = client.get()
	local clientnames

	for i, c in pairs(clients) do
		if clientnames == nil then
			clientnames = i .. ": " .. c.name
		else
			clientnames = clientnames .. "\n" .. i .. ": " .. c.name
		end
	end

	local clientname = beautiful_dmenu("echo '" ..
		-- HACK HACK FIXME PLEASE
		string.gsub(clientnames, "'", "''") ..
		"' | dmenu", "Client", true)

	if clientname ~= "" and clientname ~= nil then
		local clientnum = tonumber(string.match(clientname, '^[0-9]*'))
		local clienttable = clients[clientnum]
		awful.screen.focus(clienttable.screen)
		awful.client.jumpto(clienttable)
	end
end
-- }}}
-- {{{ Widgets
-- CPU
cpuicon = wibox.widget.imagebox(beautiful.icon_cpu)
-- cpuicon:set_resize(false)
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
	function (widget, args)
		if args[1] == 100 then
			return paint("99", theme.taglist_fg_urgent).."%"
		end
		return string.format("%02d%%", args[1])
	end, 5)
cpuwidget:buttons(awful.button({ }, 1, function() awful.util.spawn(tasks) end))
-- Clock
dataicon = wibox.widget.imagebox(beautiful.icon_clock)
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, "%R", 60)
do
	local timenot
	function showtime()
		if timenot ~= nil then naughty.destroy(timenot) end
		timenot = naughty.notify({
			text = os.date("%A %B %d %Y (%F)"),
			timeout = 5,
		})
	end
end
datewidget:buttons(awful.button({ }, 1, showtime))

-- Ram
memicon = wibox.widget.imagebox(beautiful.icon_mem)
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, "$2MiB", 10)

-- Battery
local battery_icon = { 
  beautiful.icon_bat_empty,
  beautiful.icon_bat_low,
  beautiful.icon_bat_full,
  beautiful.icon_ac,
}
local battery_icon_state = 1
local last_battery_state = "N/A"

local battery_time = "N/A"
baticon = wibox.widget.imagebox( beautiful.icon_bat_empty )
batwidget = wibox.widget.textbox()
vicious.register(batwidget, thinkpad.widget.bat,
    function (widget, args)
        -- battery_icon_state starts at 0 because of animation math
        last_battery_state = args[1]
        battery_time = args[3]
             
        local action = {
            ["charging"] = function() battery_icon_state = (battery_icon_state + 1) % 3 end,
            ["idle"] = function() battery_icon_state = 3 end,
            ["discharging"] = function()
                                if args[2] <= 5 then 
                                  battery_icon_state = 0
                                elseif args[2] <= 15 then 
                                  battery_icon_state = 1
                                else 
                                  battery_icon_state = 2
                                end
                              end,
        }
        -- apply appropiate action
        action[ args[1] or "idle" ]()
        baticon:set_image( battery_icon[battery_icon_state + 1] ) 
        return args[2] .. "%" 
    end , 2, "BAT0")
do
    local batnot
    function showbat()
        if batnot ~= nil then naughty.destroy(batnot) end
        batnot = naughty.notify({
            text = last_battery_state .. " ~" .. battery_time,
            timeout = 2,
        })
    end
end
batwidget:buttons(awful.button({ }, 1, showbat))
-- Temp
tempicon = wibox.widget.imagebox( beautiful.icon_temp )
tempwidget = wibox.widget.textbox()
vicious.register(tempwidget, vicious.widgets.thermal, "$1C", 9, {"coretemp.0", "core"})

-- Volume
volicon = wibox.widget.imagebox( beautiful.icon_speaker_low )
volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume, 
  function (widget,args) 
    if args[2] ~= "♩" then
      volicon:set_image( beautiful.icon_speaker_full )
    else
      volicon:set_image( beautiful.icon_speaker_low )
    end
    return args[1]
  end, 5, "Master")

-- Network
netupicon = wibox.widget.imagebox( beautiful.icon_net_up )
netdownicon = wibox.widget.imagebox( beautiful.icon_net_down )
nettypeicon = wibox.widget.imagebox( beautiful.icon_net_wired )
netwidget = wibox.widget.textbox()
-- nil if carrier is diconnected
function get_network_data(args, device)
  carrier = args[string.format("{%s carrier}", device)]
  up_kb   = args[string.format("{%s up_kb}", device)]
  down_kb = args[string.format("{%s down_kb}", device)]
  if carrier and carrier > 0 then                                                        
    return paint(up_kb, beautiful.net_up) .. " " .. paint(down_kb, beautiful.net_down)
  end
  return nil
end
vicious.register(netwidget, vicious.widgets.net,
function (widget, args) 
  devices = {enp0s25 = beautiful.icon_net_wired,
             wls1  = beautiful.icon_net_wifi,
            }
  for k, v in pairs(devices) do
    s = get_network_data(args, k)
    if s then
      nettypeicon:set_image(v)
      return s
    end
  end
  nettypeicon:set_image( nil )
  return ""
end, 2)
-- Spacer
spacer = wibox.widget.textbox(" ")
-- Launcher
mylauncher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = mymainmenu
})

-- Modebox widget
modebox = wibox.widget.textbox()
modebox:set_text("")
modebox:set_font("Tewi 9")

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
		function(c)
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
		function()
			if instance then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ width = 250 })
			end
		end),
	awful.button({ }, 4,
		function()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
	awful.button({ }, 5,
		function()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end))

for s = 1, screen.count() do
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function() awful.layout.inc(layouts,  1) end),
		awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function() awful.layout.inc(layouts,  1) end),
		awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)))
  -- disallow resize of the image
  mylayoutbox[s]:set_resize(false)

	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", height="15", screen = s })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()

  left_layout:add(mylayoutbox[s]) 
	left_layout:add(mytaglist[s])
	left_layout:add(spacer)
	left_layout:add(modebox)

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()

  if s == 1 then right_layout:add(systray_container) end
  right_layout:add(volicon)
  right_layout:add(volwidget)
  right_layout:add(spacer)
  right_layout:add(cpuicon)
	right_layout:add(cpuwidget)
  right_layout:add(spacer)
  right_layout:add(tempicon)
  right_layout:add(tempwidget)
  right_layout:add(spacer)
  right_layout:add(memicon)
	right_layout:add(memwidget)
  right_layout:add(spacer)
  right_layout:add(nettypeicon)
  right_layout:add(netupicon)
  right_layout:add(netwidget)
  right_layout:add(netdownicon)
  right_layout:add(spacer)
  right_layout:add(baticon)
  right_layout:add(batwidget)
  right_layout:add(spacer)
  right_layout:add(dataicon)
	right_layout:add(datewidget)
  right_layout:add(spacer)
	right_layout:add(mylauncher)

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)

	mywibox[s]:set_widget(layout)
end
-- }}}
-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
-- {{{ Modes
-- Helpers
function start_mode(mode, modetext, c)
	set_modetext(modetext)
	keygrabber.run(function(mod, key, event)
		if event ~= "press"  then return end
		if mode[key] then mode[key](c)
		else stop_mode()
		end
	end)
end

function stop_mode()
	keygrabber.stop()
	modebox.set_text(modebox, "")
end

function set_modetext(mode)
	modebox.set_markup(modebox,
	paint("∣", beautiful.fg_delimiter).." "..
	paint(mode, beautiful.fg_modebox).."  ")
end

-- Move floating windows relative to their position
function move(c, x, y)
	if floats(c) then
		local g = c:geometry()
		g.x = g.x + x
		g.y = g.y + y
		c:geometry(g)
	end
end

do
	local m = 50
	client_mode = {
		k = function(c) move(c,  0, -m) end, -- Up
		j = function(c) move(c,  0,  m) end, -- Down
		h = function(c) move(c, -m,  0) end, -- Left
		l = function(c) move(c,  m,  0) end, -- Right
		u = function(c) move(c, -m, -m) end, -- Up left
		i = function(c) move(c,  m, -m) end, -- Up right
		n = function(c) move(c, -m,  m) end, -- Down left
		m = function(c) move(c,  m,  m) end, -- Down right
	}
end

-- Super client mode
-- Move floating windows to screen edges
function snap_bydirection(c, dir)
	if not floats(c) then
		return
	end

	local g = c:geometry()
	local w = screen[c.screen].workarea

	if dir == "up" then
		g.y = 8 + w.y
	elseif dir == "down" then
		g.y = w.height - g.height + w.y - 10
	elseif dir == "left" then
		g.x = 8 + w.x
	elseif dir == "right" then
		g.x = w.width - g.width + w.x - 10
	end

	c:geometry(g)
end

super_client_mode = {
	k  = function(c) snap_bydirection(c, 'up') end,
	j  = function(c) snap_bydirection(c, 'down') end,
	h  = function(c) snap_bydirection(c, 'left') end,
	l  = function(c) snap_bydirection(c, 'right') end
}

-- This is included in all client modes
client_mode_common = {
	-- Various controls
	f = function (c) c.fullscreen = not c.fullscreen  end,
	x = function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	end,
	-- Launch terminal
	q = function()
		awful.util.spawn(terminal)
	end
}

client_mode       = awful.util.table.join(client_mode, client_mode_common)
super_client_mode = awful.util.table.join(super_client_mode, client_mode_common)

-- Media mode
do
	local cover_notify
	function mpd_art_notify()
		if cover_notify ~= nil then
			naughty.destroy(cover_notify)
		end

		local cover = awful.util.pread("albumart")
		local text  = awful.util.pread("musicinfo")

		cover_notify = naughty.notify({
			icon = cover,
			icon_size = 80,
			text = text,
			position = "top_right"
		})
	end
end

function mpc(cmd)
	os.execute("mpc --quiet "..cmd)
end

media_mode = {
	-- Love
	f = function ()
		local text  = awful.util.pread("mpdlove")
		naughty.notify({
			text = text,
			position = "top_right"
		})
	end,
	-- Start/stop
	j = function () mpc("toggle &") end,
	k = function () mpc("stop &")   end,
	-- Next/prev
	l = function () mpc("next &") end,
	h = function () mpc("prev &") end,
	-- Seeking
	s = function () mpc("seek +10 &") end,
	a = function () mpc("seek -10 &") end,
	-- Mpc playback modes
	y = function () mpc("single &") end,
	z = function () mpc("random &") end,
	r = function () mpc("repeat &") end,
	-- Album art notification
	d = function ()
		mpd_art_notify()
		print (cover_notify)
	end,
}

-- }}}
-- {{{ Globalkeys
globalkeys = awful.util.table.join(
	-- Media mode
		awful.key({ modkey,  }, "d", function ()
		-- TODO: new music glyph
		start_mode(media_mode, "♫")
	end),

	-- Restart Awesome
	awful.key({ modkey, "Control" }, "r", awesome.restart),

	-- Tags
	awful.key({ modkey, "Control" }, "h", awful.tag.viewprev),
	awful.key({ modkey, "Control" }, "l", awful.tag.viewnext),

	-- Escape from focus traps (eg Flash plugin in Firefox)
	awful.key({ modkey,           }, "z", function () awful.util.spawn("clickwin") end),

	-- Tab
	awful.key({ modkey, "Control" }, "Tab", function () awful.screen.focus_relative(1) end),
	awful.key({ modkey, "Shift"   }, "Tab", awful.tag.history.restore),
	awful.key({ modkey,           }, "Tab",
	  function ()
	  	awful.client.focus.history.previous()
	  	if client.focus then
	  		client.focus:raise()
	  	end
	  end),

	-- Standard programs
	awful.key({ modkey,           }, "q", function () awful.util.spawn(terminal)   end),
	awful.key({ modkey,           }, "b", function () awful.util.spawn(browser)    end),
	awful.key({ modkey,           }, "v", function () awful.util.spawn(editor)     end),
  awful.key({ modkey,           }, "w", function () awful.util.spawn(files)      end),

	-- Search for clients
	awful.key({ modkey,           }, "m", dmenu_raise),

	-- Run
	awful.key({ modkey,           }, "r", function ()
		local cmd = beautiful_dmenu("yeganesh -x -p programs --", "Run", true)
		awful.util.spawn(cmd)
	end),

	-- Search mpd playlist
	awful.key({ modkey,           }, "n", function ()
		beautiful_dmenu("dmenu_play", "Song")
	end),

	-- Pick album, then song
	awful.key({ modkey, "Shift"   }, "m", function ()
		beautiful_dmenu("yeganesh_album", "Album")
	end),

	awful.key({ modkey,           }, "t", function ()
		if systray_container.widget == nil then
			systray_container:set_widget(systray)
		else
			awesome.systray(stupid_bug, 0, 0, 10, true, "#000000")
			systray_container:set_widget(nil)
		end
	end),


	-- Managing clients
	awful.key({ modkey, "Shift"   }, "h", function () swpbydir("left" ) end),
	awful.key({ modkey, "Shift"   }, "j", function () swpbydir("down" ) end),
	awful.key({ modkey, "Shift"   }, "k", function () swpbydir("up"   ) end),
	awful.key({ modkey, "Shift"   }, "l", function () swpbydir("right") end),
	awful.key({ modkey,           }, "h", function () focbydir("left" ) end),
	awful.key({ modkey,           }, "j", function () focbydir("down" ) end),
	awful.key({ modkey,           }, "k", function () focbydir("up"   ) end),
	awful.key({ modkey,           }, "l", function () focbydir("right") end),

	awful.key({ modkey, "Shift"   }, ".", awful.client.restore),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

	-- Layout manipulation
	awful.key({ modkey,           }, "s", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey,           }, "a", function () awful.layout.inc(layouts, -1) end),

	-- Lock Xorg
	awful.key({                   }, "XF86ScreenSaver", function () awful.util.spawn("slock")  end),

	-- Crop a screenshot
	awful.key({ modkey,           }, "c",      function () awful.util.spawn("cscrot") end),

    -- Volume
    awful.key({                   }, "XF86AudioRaiseVolume", function () 
                                                            awful.util.spawn("amixer set Master playback 1%+")
                                                            vicious.force({volwidget})
                                                        end),
    awful.key({                   }, "XF86AudioLowerVolume", function () 
                                                            awful.util.spawn("amixer set Master playback 1%-")
                                                            vicious.force({volwidget})
                                                        end),
    awful.key({                   }, "XF86AudioMute", function () 
                                                            awful.util.spawn("amixer set Master playback toggle")
                                                            vicious.force({volwidget})
                                                        end),  
	-- Power button
	awful.key({                   }, "XF86PowerOff", function () awful.util.spawn("systemctl suspend")  end),
	awful.key({ modkey,           }, "XF86PowerOff", function () awful.util.spawn("systemctl poweroff") end),
	awful.key({ modkey, "Control" }, "XF86PowerOff", function () awful.util.spawn("systemctl reboot")   end)
  )
-- }}}
-- {{{ Clientkeys/buttons
clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen end),
	awful.key({ modkey,           }, "x",      function (c) c:kill() end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",      awful.client.movetoscreen),
	awful.key({ modkey,           }, ".",      function (c) c.minimized = true end),
	awful.key({ modkey,           }, "space",
	function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	end),

	awful.key({ modkey,  }, "g", function (c)
		start_mode(super_client_mode, "SC", c)
	end),
	awful.key({ modkey,  }, "e", function (c)
		start_mode(client_mode, "C", c)
	end)
)

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
--    awful.button({ modkey }, 9, function () awful.util.spawn("") end), --up
--    awful.button({ modkey }, 8, function () awful.util.spawn("") end), --down
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- }}}
-- {{{ Generated keys
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
	keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
	globalkeys = awful.util.table.join(globalkeys,
	awful.key({ modkey }, "#" .. i + 9,
	function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewonly(tags[screen][i])
		end
	end),
	awful.key({ modkey, "Control" }, "#" .. i + 9,
	function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewtoggle(tags[screen][i])
		end
	end),
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
	function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.movetotag(tags[client.focus.screen][i])
		end
	end),
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
	function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.toggletag(tags[client.focus.screen][i])
		end
	end))
end

-- Set keys
root.keys(globalkeys)
-- }}}
-- {{{ Rules
require("awful.rules").rules = {
	{ rule       = {},
	  properties = {
		  border_color = beautiful.border_normal,
		  border_width = beautiful.border_width,
		  buttons      = clientbuttons,
		  focus        = awful.client.focus.filter,
		  keys         = clientkeys,
	  },
    callback   = awful.client.setslave 
  },
  { rule       = { class = "Steam" },
    properties = { floating = true } },
	{ rule       = { name = "Xonotic" },
	  properties = { fullscreen = true } },
}
-- }}}
-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
 -- c:connect_signal("mouse::enter", function(c)
 --   if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
 -- 	  and awful.client.focus.filter(c) then
 -- 	  client.focus = c
 --   end
 -- end)

	local clayout = awful.layout.getname(awful.layout.get(c.screen))
	if clayout ~= "floating"
		or c.maximized_horizontal
		or c.maximized_vertical
		or c.fullscreen then
		c.size_hints_honor = false
	else
		c.size_hints_honor = true
	end

	-- No icons
	c.icon = nil

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		--        awful.client.setslave(c)

		-- Put windows in a smart way
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	else
		local g = c:geometry()
		g.x = g.x - beautiful.border_width
		g.y = g.y - beautiful.border_width
		c:geometry(g)
	end
end)

-- size_hints_honor = false only for non-floating clients
for s = 1, screen.count() do
	for t = 1, #tags[s] do
		tags[s][t]:connect_signal("property::layout", function ()
			tag_clients   = tags[s][t]:clients()
			tag_clients_n = #tag_clients
			if awful.layout.get(s) == awful.layout.suit.floating then
				for n = 1, tag_clients_n do
					tag_clients[n].size_hints_honor = true
				end
			else
				for n = 1, tag_clients_n do
					if not awful.client.floating.get(tag_clients[n]) then
						tag_clients[n].size_hints_honor = false
					end
				end
			end
		end)
	end
end
-- }}}
-- vim: set fdm=marker :
