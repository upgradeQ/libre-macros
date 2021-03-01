# Description 
**obs-libre-macros** is an Extension for OBS Studio built on top of its scripting facilities,
utilising built-in embedded LuaJIT interpreter, filter UI and function environment from Lua 5.2
# Screenshot

![img](https://i.imgur.com/10IrnOu.png)

# Features 
- Attach `Console` to **any** source in real-time.
- **Auto run** code when OBS starts, **load from file**, **Hot reload** expressions.
- Hotkeys support for each `Console` instance.
- Integration with 3-rd party plugins and scripts via `obs_data_json_settings` e.g:
  - [move transition](https://github.com/exeldro/obs-move-transition) - latest versions include `audio move filter` which monitors source volume level.
  - [websocket](https://github.com/Palakis/obs-websocket) - control obs through WebSockets
- Less boilerplate: an environment provided with already defined namespace.
  - `t.source` - access source reference unique to each `Console` instance.
  - `t.pressed` - access hotkey state.
  - `sleep(seconds)` - command to pause execution.
  - `t.tasks` - asynchronous event loop.
  - `obslua` - accessed via `obs` and `obsffi` - native linked library.
  - Share GLOBAL state between `Console` instances via `gn` - global namespace.
  - `t.<setting_name>` - various settings
- Crossplatform, works offline.
- View output of `print` in `Script Log`.
```diff
+Browser source keyboard and mouse interaction+
```

# Installation 
- One time setup 
- Download source code, unpack/unzip.
- Add `console.lua` to OBS Studio via Tools > Scripts > "+" button
---
# Usage 

- Left click on any source, add `Console` filter to it.
- Open `Script Log` to view `Console` output.
- Type some code into the text area.
- Press `Execute!`.
- Sample code: `print(obs.obs_frontend_get_current_scene_collection())`

# REPL usage

Each Console instance has it's own namespace `t`,
you can access source which Console is attached to.
You can do this by writing this: 
```lua
print(obs.obs_source_get_name(t.source)) 
```
Note: use of `local`, if you decide to not to use it, variable will become global and all Console
instances can access it. So if you want to save some state particular to Console
instance you'd better write this:
```lua
local this_source_note = "sample text"
t.this_source_note = this_source_note
-- or
t.k = 'value'
```
Later if you want to change it you'd write:
```lua
t.this_source_note = "samplex text updated at"  .. os.date(" %X ")
print(t.this_source_note)
```

# Auto run
If you check `Auto run` then code from this console will be executed automatically 
when OBS starts.

# Loading from file 
To load from file you need first select which one to load from properties,
see "Settings for internal use", then paste this template into text area:
```lua
local _ENV = _G
_ENV.t = __t
local f = loadfile(t.p1,nil,"t",_ENV)
success, result = pcall(f)
if not success then print(result) end
```
# Hotkeys usage
There are 2 types of hotkeys:
 - First,can be found in settings with prefixed `0;` - it will execute code in text area
 - Second, prefixed with `1;`- it will mutate `t.pressed` state

# Examples
High frequency blinking source:  
- [x] Auto run
```lua
while true do 
sleep(0.03)
obs.obs_source_set_enabled(t.source,true) 
sleep(0.03)
obs.obs_source_set_enabled(t.source,false) 
end
```

Print source name while holding hotkey:
```lua
repeat
sleep(0.1)
if t.pressed then print_source_name(t.source) end 
until false 
```

Hot reload with delay:
```lua
print('restarted') -- expression print_source_name(t.source)
local delay = 0.5
while true do
local f=load('local t= __t;' .. t.hotreload)
success, result = pcall(f)
if not success then print(result) end
sleep(delay)
end
```
Shake a text source and update its text based on location from scene (using code from [wiki](https://github.com/obsproject/obs-studio/wiki/Scripting-Tutorial-Source-Shake))
Paste into `Console` or load from file this code:
```lua
function get_sceneitem_from_source_name_in_current_scene(name)
  local result_sceneitem = nil
  local current_scene_as_source = obs.obs_frontend_get_current_scene()
  if current_scene_as_source then
    local current_scene = obs.obs_scene_from_source(current_scene_as_source)
    result_sceneitem = obs.obs_scene_find_source_recursive(current_scene, name)
    obs.obs_source_release(current_scene_as_source)
  end
  return result_sceneitem
end
local source_name = obs.obs_source_get_name(t.source)
local sceneitem = get_sceneitem_from_source_name_in_current_scene(source_name)
local amplitude , shaken_sceneitem_angle , frequency = 10,0,2
local pos = obs.vec2()

local function update_text(source,text)
  local settings = obs.obs_data_create()
  obs.obs_data_set_string(settings, "text", text)
  obs.obs_source_update(source, settings)
  obs.obs_data_release(settings)
end
local function get_position(opts)
  return "pos x: " .. opts.x .. " y: " .. opts.y
end
repeat 
  sleep(0) -- sometimes obs freezes if sceneitem is dragged
  local angle = shaken_sceneitem_angle + amplitude*math.sin(os.clock()*frequency*2*math.pi)
  obs.obs_sceneitem_set_rot(sceneitem, angle)
  obs.obs_sceneitem_get_pos(sceneitem,pos)
  local result = get_position { x = pos.x, y = pos.y }
  update_text(t.source,result)
until false
```

Print a source name every second while also print current filters attached to source in `t.tasks`, shutdown this task after 10 seconds

```lua
function print_filters()
  repeat
  local filters_list = obs.obs_source_enum_filters(t.source)
  for _,fs in pairs(filters_list) do
    print_source_name(fs)
  end
  obs.source_list_release(result)
  sleep(math.random())
  until false
end

t.tasks[1] = run(print_filters)
function shutdown_all()
 for task,_coro in pairs(t.tasks) do 
   t.tasks[task] = nil
 end
end

t.tasks[2] = run(function()
  sleep(10)
  shutdown_all()
end)

repeat 
sleep(1)
print_source_name(t.source)
until false
```
Using [move-transition plugin](https://obsproject.com/forum/resources/move-transition.913/) with its move-audio filter, redirect to `t.mv2`, then show value of `t.mv2` in `Script Log`
- [x] Headphones on
```lua
repeat 
sleep(0.3)
print(t.mv2)
until false
```

Attach volmeter to source with sound(same as above, but without plugin):

```lua
volume_level(return_source_name(t.source))
repeat
sleep(1)
print(LVL)
print(NOISE)
until false
```

Start virtual camera as a triggered named callback:

```lua
local description = 'OBSBasic.StartVirtualCam'
trigger_from_hotkey_callback(description)
```

Send hotkey combination to OBS:
```lua
send_hotkey('OBS_KEY_2',{shift=true})
```

Hook state of right and left mouse buttons:
```lua
hook_mouse_buttons()
repeat 
sleep(0.1)
print(tostring(LMB))
print(tostring(RMB))
until false
```

Access sceneitem from scene:
```lua
local sceneitem = get_scene_sceneitem("Scene 2",sname(t.source))
repeat 
sleep(0.01)
if sceneitem then
  obs.obs_sceneitem_set_rot(sceneitem, math.sin(math.random() * 100))
  end
until false
```
Route audio move value filter from obs-move-transition to change console settings
Attach console to image source, add images to directory with `console.lua`
In audio move set `Input Peak Sample`,select `Move value[0,100] 1` base value `1`, factor `100`
```lua
function update_image(state)
  local settings = obs.obs_data_create()
  obs.obs_data_set_string(settings, "file", script_path() .. state)
  obs.obs_source_update(t.source, settings)
  obs.obs_data_release(settings)
end
local skip,scream,normal,silent = false,30,20,20
while true do ::continue::
  sleep(0.03)
  if t.mv2 > scream then update_image("scream.png") skip = false
    sleep(0.5) goto continue end
  if t.mv2 > normal then update_image("normal.png") skip = false
    sleep(0.3) goto continue
  end -- pause for a moment then goto start
  if t.mv2 < silent then if skip then goto continue end
    update_image("silent.png") 
    skip = true -- do not update afterwards
  end
end
```
Result:
![gif](https://i.imgur.com/4HysoIE.gif)

# Browser source interaction
## Send mouse move 
```lua
repeat sleep(1)
send_mouse_move_tbs(t.source,12,125) 
local get_t = function() return math.random(125,140) end
for i=12,200,6 do 
  sleep(0.03)
  send_mouse_move_tbs(t.source,i,get_t()) 
end
until false
```
Example gif - 2 consoles are sending mouse move events into browser sources:
![gif](https://i.imgur.com/gI6LbRF.gif)
Website link: <https://zennohelpers.github.io/Browser-Events-Testers/Mouse/Mouse.html?>

## Send Click
```lua
repeat sleep(1)
--send_mouse_move_tbs(t.source,95,80) -- 300x300 browser source
_opts = {x=95,y=80,button_type=obs.MOUSE_LEFT,mouse_up=false,click_count=0}
send_mouse_click_tbs(t.source,_opts) 
-- here might be delay which specifies how long mouse is pressed
_opts.mouse_up,_opts.click_count = true,2
send_mouse_click_tbs(t.source,_opts) 
until false
```
## Wheel does not work
```lua
repeat sleep(1)
--send_mouse_move_tbs(t.source,95,80) -- 300x300 browser source
_opts = {x=95,y=80,y_delta=3}
send_mouse_wheel_tbs(t.source,_opts) 
until false
```
## Keyboard interaction
```lua
-- Send tab
send_hotkey_tbs1(t.source,"OBS_KEY_TAB",false)
send_hotkey_tbs1(t.source,"OBS_KEY_TAB",true)

-- Send tab with shift modifier
send_hotkey_tbs1(t.source,"OBS_KEY_TAB",false,{shift=true})
send_hotkey_tbs1(t.source,"OBS_KEY_TAB",true,{shift=true})

send_hotkey_tbs1(t.source,"OBS_KEY_RETURN",false)
send_hotkey_tbs1(t.source,"OBS_KEY_RETURN",true)


-- char_to_obskey (ASCII only)
send_hotkey_tbs1(t.source,char_to_obskey('j'),false,{shift=true})
send_hotkey_tbs1(t.source,char_to_obskey('j'),true,{shift=true})
-- or use
send_hotkey_tbs1(t.source,c2o('j'),false)
send_hotkey_tbs1(t.source,c2o('j'),true)
-- might work with unicode input
send_hotkey_tbs2(t.source,'q'false)
send_hotkey_tbs2(t.source,'й',false)
```

# Contribute
Contributions are welcome!
# Roadmap 
- Implement `obs.timer_add` as loop executor
- Inject custom shader/effect and custom rendering for filter and for source
- Hook keyboard, hook mouse position for winapi and x11 using cdefs
- Add predefined templates with examples and multiple text areas to take code from
- Python bidirectional communication via `obs_data_json` structures

# License
<a href="https://www.gnu.org/licenses/agpl-3.0.en.html">
<img src="https://www.gnu.org/graphics/agplv3-with-text-162x68.png" align="right" />
</a>

The **obs-libre-macros** is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. That means that if users interacting with it remotely through a network then: If you **not** modified it, then you can direct them [here](https://github.com/upgradeQ/obs-libre-macros), if you **modified** it, you simply have to publish your modifications. The easiest way to do this is to have a public Github repository of your fork or create a PR upstream. Otherwise, you will be in violation of the license. The relevant part of the license is under section 13 of the AGPLv3.  
