# Description 
**obs-libre-macros** is an Extension for OBS Studio built on top of its scripting facilities,
utilising built-in embedded LuaJIT interpreter, filter UI and function environment from Lua 5.1

# Features 
- Attach `Console` to **any** source in real-time
- **Auto run** code when OBS starts, **load from file**, **Hot reload** expressions
- Hotkeys support for each `Console` instance.
- Integration with 3-rd party plugins and scripts via `obs_data_json_settings` e.g:
  - [move transition](https://github.com/exeldro/obs-move-transition) - latest versions include `audio move filter` which monitors source volume level
  - [websocket](https://github.com/Palakis/obs-websocket) - control obs through WebSockets
- Less boilerplate: an environment provided with already defined namespace and useful functions
  - `source` - access source reference unique to each `Console` instance
  - `t.pressed` - access hotkey state
  - `sleep(seconds)` - command to pause execution
  - `t.tasks` - asynchronous event loop
  - `obsffi` - accessed via `obsffi` - native linked library
  - View and change **all** settings for source, and for filter in that source 
  - Send, pause, resume, switch, recompile `Console` instances via GLOBAL(per OBS Studio instance) multi actions pipes
  - Read and write private data, execute Python from Lua, and Lua from Python
  - Create hollow gaps 
- Crossplatform, works offline, supports two languages for UI English and Russian
```diff
+Browser source keyboard and mouse interaction+
```

# Installation 
- Download [source code](https://github.com/upgradeQ/obs-libre-macros/archive/master.zip), unpack/unzip.
- Add `console.lua` to OBS Studio via Tools > Scripts > "+" button
---
# Usage 

- Left click on any source, add `Console` filter to it.
- Open `Script Log` to view `Console` output.
- Type some code into the text area.
- Press `Execute!`.
- Sample code: `print(obs_frontend_get_current_scene_collection())`
- [Examples & Cheatsheet (python)](https://github.com/upgradeQ/OBS-Studio-Python-Scripting-Cheatsheet-obspython-Examples-of-API)

# REPL usage

Each Console instance has it's own namespace `t` and custom environment,
you can access source which Console is attached to. e.g:
```lua
print(obs_source_get_name(source)) 
```
To access global the state of script do it via `_G`, when you write x = 5,
only that instance of `Console` will have it.

# Auto run
If you check `Auto run` then code from this console will be executed automatically 
when OBS starts.

# Loading from file 
To load from file you need first select which one to load from properties,
see "Settings for internal use", then paste this template into text area:
```lua
local f = loadfile(t.p1, "t",getfenv(1))
success, result = pcall(f)
if not success then print(result) end
```
# Hotkeys usage
There are 2 types of hotkeys:
 - First, can be found in settings with prefixed `0;` - it will execute code in text area
 - Second, prefixed with `1;`, `2;`, `3;` - it will mutate `t.pressed`, `t.pressed2`, `t.pressed3` states

# Examples
High frequency blinking source:  
- [x] Auto run
```lua
while true do 
sleep(0.03)
obs_source_set_enabled(source, true) 
sleep(0.03)
obs_source_set_enabled(source, false) 
end
```

Print source name while holding hotkey:
```lua
repeat
sleep(0.1)
if t.pressed then print_source_name(source) end 
until false 
```

Hot reload with delay:
```lua
print('restarted') -- expression print_source_name(source)
local delay = 0.5
while true do
local f=load( t.hotreload)
setfenv(f,getfenv(1))
success, result = pcall(f)
if not success then print(result) end
sleep(delay)
end
```
Shake a text source and update its text based on location from scene (using code from [wiki](https://github.com/obsproject/obs-studio/wiki/Scripting-Tutorial-Source-Shake))
Paste into `Console` or load from file this code:
```lua
local source_name = obs_source_get_name(source)
local _name = "YOUR CURRENT SCENE NAME YOU ARE ON"
local sceneitem = get_scene_sceneitem(_name, return_source_name(source))
local amplitude , shaken_sceneitem_angle , frequency = 10, 0, 2
local pos = vec2()

local function update_text(source, text)
  local settings = obs_data_create()
  obs_data_set_string(settings, "text", text)
  obs_source_update(source, settings)
  obs_data_release(settings)
end
local function get_position(opts)
  return "pos x: " .. opts.x .. " y: " .. opts.y
end
repeat 
  sleep(0) -- sometimes obs freezes if sceneitem is double clicked
  local angle = shaken_sceneitem_angle + amplitude*math.sin(os.clock()*frequency*2*math.pi)
  obs_sceneitem_set_rot(sceneitem, angle)
  obs_sceneitem_get_pos(sceneitem, pos)
  local result = get_position { x = pos.x, y = pos.y }
  update_text(source, result)
until false
```

Print a source name every second while also print current filters attached to
source in `t.tasks`, shutdown this task after 10 seconds

```lua
function print_filters()
  repeat
  local filters_list = obs_source_enum_filters(source)
  for _, fs in pairs(filters_list) do
    print_source_name(fs)
  end
  source_list_release(filters_list)
  sleep(math.random())
  until false
end

t.tasks[1] = run(print_filters)
function shutdown_all()
 for task, _coro in pairs(t.tasks) do 
   t.tasks[task] = nil
 end
end

t.tasks[2] = run(function()
  sleep(10)
  shutdown_all()
end)

repeat 
sleep(1)
print_source_name(source)
until false
```
Using [move-transition plugin](https://obsproject.com/forum/resources/move-transition.913/) with its move-audio filter, redirect to `t.mv2`, then show value of `t.mv2` in `Script Log`
```lua
repeat 
sleep(0.3)
print(t.mv2)
until false
```

Start virtual camera as a triggered named callback:

```lua
local description = 'OBSBasic.StartVirtualCam'
trigger_from_hotkey_callback(description)
```

Send hotkey combination to OBS:
```lua
send_hotkey('OBS_KEY_2', {shift=true})
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
local sceneitem = get_scene_sceneitem("Scene 2", sname(source))
repeat 
sleep(0.01)
if sceneitem then
  obs_sceneitem_set_rot(sceneitem, math.sin(math.random() * 100))
  end
until false
```
Route audio move value filter from obs-move-transition to change console settings
Attach console to image source, add images to directory with `console.lua`
In audio move set `Input Peak Sample`, select `Move value[0, 100] 1` base value `1`, factor `100`
```lua
function update_image(state)
  local settings = obs_data_create()
  obs_data_set_string(settings, "file", script_path() .. state)
  obs_source_update(source, settings)
  obs_data_release(settings)
end
local skip, scream, normal, silent = false, 30, 20, 20
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
send_mouse_move_tbs(source, 12, 125) 
local get_t = function() return math.random(125, 140) end
for i=12, 200, 6 do 
  sleep(0.03)
  send_mouse_move_tbs(source, i, get_t()) 
end
until false
```
Example gif - 2 consoles are sending mouse move events into browser sources:
![gif](https://i.imgur.com/gI6LbRF.gif)
Website link: <https://zennohelpers.github.io/Browser-Events-Testers/Mouse/Mouse.html?>

## Send Click
```lua
repeat sleep(1)
--send_mouse_move_tbs(source, 95, 80) -- 300x300 browser source
_opts = {x=95, y=80, button_type=MOUSE_LEFT, mouse_up=false, click_count=0}
send_mouse_click_tbs(source, _opts) 
-- here might be delay which specifies how long mouse is pressed
_opts.mouse_up, _opts.click_count = true, 2
send_mouse_click_tbs(source, _opts) 
until false
```
## Wheel does not work with default CSS
Note: currently does not work on 27.2.4 
```lua
repeat sleep(1)
--send_mouse_move_tbs(source, 95, 80) -- 300x300 browser source
_opts = {x=95, y=80, y_delta=3}
send_mouse_wheel_tbs(source, _opts) 
until false
```
## Keyboard interaction
```lua
-- Send tab
send_hotkey_tbs1(source, "OBS_KEY_TAB", false)
send_hotkey_tbs1(source, "OBS_KEY_TAB", true)

-- Send tab with shift modifier
send_hotkey_tbs1(source, "OBS_KEY_TAB", false, {shift=true})
send_hotkey_tbs1(source, "OBS_KEY_TAB", true, {shift=true})

send_hotkey_tbs1(source, "OBS_KEY_RETURN", false)
send_hotkey_tbs1(source, "OBS_KEY_RETURN", true)


-- char_to_obskey (ASCII only)
send_hotkey_tbs1(source, char_to_obskey('j'), false, {shift=true})
send_hotkey_tbs1(source, char_to_obskey('j'), true, {shift=true})
-- or use
send_hotkey_tbs1(source, c2o('j'), false)
send_hotkey_tbs1(source, c2o('j'), true)
-- might work with unicode input
send_hotkey_tbs2(source, 'q', false)
send_hotkey_tbs2(source, 'й', false)
```

## Execute python(must load helper script)
```lua
exec_py(
[=[def print_hello():
   print('hello world')
   a = [ x for x in range(10) ][0]
   return a
print_hello()
]=])
```
## React on source signals
```lua
register_on_show(function()
print('on show')
sleep(3)
print('on show exit')
 end)
```
## Run multiactions
### Example
`Console` instance with this entries in first and second text area.
```lua
okay("pipe1")
print('exposing pipe 1')
```
Actual code, write it in second text area in each instance of `Console`
```lua
print(os.time()) print('  start 11111') ; sleep (0.5) ; print(os.time())
print_source_name(source) ; sleep(2) print('done 11111')
```
Another `Console` instance with same code first text area but different in second
```lua
okay("pipe2")
print('exposing pipe 2')
```
And in multiaction text area add this
```lua
print(os.time()) print('start ss22222ssssss2ss') ; sleep (2.5 ) ; print(os.time())
print_source_name(source) ; sleep(2) print('done 2222')
```
Main `Console` instance. This will start `pipe1` then after sec `pipe2`
```
offer('pipe1')
sleep(1)
offer('pipe2')
```
- `okay` - exposes actions
- `offer` - starts actions
- `stall` - pause
- `forward` - continue
- `switch` - pause/continue
- `recompile` - restarts actions

# Gaps sources
***Only usable through attaching via filter to scene (not groups)***

- Add gap:
```lua
add_gap {x=300,y=500, width = 100, height = 100}
```
- Add outer gaps - `add_outer_gap(100)`
- Resize outer gaps - `resize_outer_gaps(30)`
- Delete all gaps on scene - `delete_all_gaps()`

# View and set settings
- `print_settings(source)` - shows all settings
- `print_settings2(source, filter_name)` - shows all settings for a filter on that source
- `set_settings2(source, filter_name, opts)` - sets one settings
- `set_settings3(source, filter_name, json_string)` - sets one settings
- `set_settings4(source,  json_string)` - sets settings for source

Examples: 

```lua
set_settings2(source, "Color Correction", {_type ="double", _field= "gamma", _value= 0})
```

```lua
local my_json_string = [==[
{"brightness":0.0,"color_add":0,"color_multiply":16777215,
"contrast":0.0,"gamma":0.0,"hue_shift":0.0,"opacity":1.0,"saturation":0.0}
]==]
set_settings3(source, "Color Correction", my_json_string)
```
# Useful functions
Also read source to know exactly how they work in section which defines general purpose functions.

`execute(command_line, current_directory)` - executes command line command without console blinking WINDOWS ONLY
Example:
```lua
if execute[["C:\full\path\to\python.exe" "C:\Users\YOUR_USERNAME\path\to\program.py" ]] then
error('done') else error('not done') end
```

`pp_execute` - works roughly same as above, based on util.h from libobs [see also](https://github.com/obsproject/obs-studio/commit/225f597379dd0af56f749374a07bea1f7beebf6e)

`sname(source)` - returns source name as string

`sceneitem = get_scene_sceneitem(scene_name, scene_item_name)`


# Contribute
Contributions are welcome! You might take a look into source code for translation of UI to your language.

# On the Roadmap 
- Inject custom shader/effect and custom rendering for filter and for source.
There is pure Lua custom shader loader [here](https://github.com/ps0ares/CustomShaders).
Add shaders to transform source in 3D and 2D programmatically 
- Hook keyboard, hook mouse position for winapi and x11 using cdefs
- Add predefined templates with examples
- Apply special functionality to each type of source,e.g add special functions, redesign properties
- Add more features and functions to browser source

# License
<a href="https://www.gnu.org/licenses/agpl-3.0.en.html">
<img src="https://www.gnu.org/graphics/agplv3-with-text-162x68.png" align="right" />
</a>

The **obs-libre-macros** is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. That means that IF users interacting with it remotely(through a network) - they are entitled to source code. And if it is **not** modified, then you can direct them [here](https://github.com/upgradeQ/obs-libre-macros), but if you had **modified** it, you simply have to publish your modifications. The easiest way to do this is to have a public Github repository of your fork or create a PR upstream. Otherwise, you will be in violation of the license. The relevant part of the license is under section 13 of the AGPLv3.  
