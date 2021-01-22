# Description 
**obs-libre-macros** is an Extension for OBS Studio built on top of its scripting facilities,
utilising built-in embedded LuaJIT interpreter, filter UI and function environment from Lua 5.2

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
- Crossplatform.
- View output of `print` in `Script Log`.

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


# License
<a href="https://www.gnu.org/licenses/agpl-3.0.en.html">
<img src="https://www.gnu.org/graphics/agplv3-with-text-162x68.png" align="right" />
</a>

The **obs-libre-macros** is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. That means that if users interacting with it remotely through a network: If you **not** modified, then you can direct them [here](https://github.com/upgradeQ/obs-libre-macros), if you **modified** it, you simply have to publish your modifications. The easiest way to do this is to have a public Github repository of your fork or create a PR upstream. Otherwise, you will be in violation of the license. The relevant part of the license is under section 13 of the AGPLv3.  
