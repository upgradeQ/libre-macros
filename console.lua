copyleft = [[
obs-libre-macros - scripting and macros hotkeys in OBS Studio for Humans
Contact/URL https://www.github.com/upgradeQ/obs-libre-macros
Copyright (C) 2021 upgradeQ

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]
print(copyleft)
obs_libre_macros_version = "2.0.0"

function script_description()
  return copyleft:sub(1, 163) .. 'Version: ' .. obs_libre_macros_version ..
  '\nReleased under GNU Affero General Public License, AGPLv3+'
end

function open_package(ns)
  for n, v in pairs(ns) do _G[n] = v end
end

open_package(obslua)
ffi = require "ffi" -- for native libs and C code access
jit = require "jit" -- for C thread callback behavior change
bit = require "bit" -- binary logic

function try_load_library(alias, name)
  if ffi.os == "OSX" then name = name .. ".0.dylib" end
  ok, _G[alias] = pcall(ffi.load, name)
  if not ok then 
    print(("WARNING:%s:Has failed to load, %s is nil"):format(name, alias))
  end
end

try_load_library("obsffi", "obs")
--try_load_library("frontendC", "frontend-api")
--try_load_library("openglC", "opengl")
--try_load_library("scriptingC", "scripting")

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

local Timer = {}
function Timer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Timer:update(dt)
  self.current_accumulated_time = self.current_accumulated_time + dt
  if self.current_accumulated_time >= self.duration then
    self.finished = true
  end
end

function Timer:enter()
  self.finished = false
  self.current_accumulated_time = 0
end

function Timer:launch()
  self:enter()
  while not self.finished do
    local dt = coroutine.yield()
    self:update(dt)
  end
end

function sleep(s)
  local action = Timer:new{duration=s}
  action:launch()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
-- function script_tick(dt) end -- external loop, can be used for messaging/signalling

run = coroutine.create
init = function() return run(function() coroutine.yield() end) end
gn = {}
SUB = {} -- {{"pipe_name": num_code}, ...}

_OFFER = 111;function offer(pipe_name) SUB[pipe_name] = _OFFER end
_STALL = 222;function stall(pipe_name) SUB[pipe_name] = _STALL end
_FORWARD = 333;function forward(pipe_name) SUB[pipe_name] = _FORWARD end
_SWITCH = 444;function switch(pipe_name) SUB[pipe_name] = _SWITCH end

function executor(ctx, code, loc, name) -- args defined automatically  as local
  local _ENV = _G
  loc = loc or "exec"
  name = name or "obs repl"
  _ENV["__t"] = ctx
  code = code or _ENV.__t.code
  _ENV.__t.source = obs_filter_get_parent(ctx.filter)
  _ENV.pr1 = function() print_source_name(_ENV.t.source) end
  local exec = assert(load(CODE_STORAGE .. code, name, "t"))
  -- executor submits code to event loop, which will execute it with .resume
  ctx[loc] = run(exec)
end

function skip_tick_render(ctx)
  local target = obs_filter_get_target(ctx.filter)
  local width, height;
  if target == nil then width = 0; height = 0; else
    width = obs_source_get_base_width(target)
    height = obs_source_get_base_height(target)
  end
  ctx.width, ctx.height = width , height
end

function viewer()
  error(">Script Log")
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

local SourceDef = {}

function SourceDef:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function SourceDef:_set_timer_loop() 
  local interval, ms = 1/60 , 16 -- change if higher fps
  timer_add(function() SourceDef._event_loop(self, interval) end, ms)
  self.loop_executor_timer = true
end

function SourceDef:create(source)
  local instance = {}
  instance.filter = source -- filter source itself
  instance.hotkeys = {}
  instance.hk = {}
  instance.pressed = false
  instance.created_hotkeys = false

  instance.button_dispatch = false
  instance.preload = true
  instance.hotkey_dispatch = false
  instance.actions_dispatch = false
  instance.is_action_paused = false

  instance.tasks = {}
  instance.exec = init()
  instance.external_py = init()
  instance.exec_action_code = init()
  instance.on_show_task = init()
  instance.on_hide_task = init()
  instance.on_activate_task = init()
  instance.on_deactivate_task = init()

  if obs_source_get_unversioned_id(source):find("timer") then 
    SourceDef._set_timer_loop(instance)
  end
  SourceDef.update(instance, self) -- self = settings
  return instance
end

function SourceDef:update(settings)
  self.code = obs_data_get_string(settings, "_text")
  self.action_code = obs_data_get_string(settings, "_action")
  self.autorun = obs_data_get_bool(settings, "_autorun")
  self.mv1 = obs_data_get_double(settings, "_mv1")
  self.mv2 = obs_data_get_double(settings, "_mv2")
  self.hotreload = obs_data_get_string(settings, "_hotreload")
  self.p1 = obs_data_get_string(settings, "_p1")
  self.p2 = obs_data_get_string(settings, "_p2")

  if not self.created_hotkeys then
    SourceDef._reg_htk(self, settings)
  end
end

function SourceDef:_event_loop(seconds)
  -- button restarts code on click 
  -- actions and external python do same
  -- hotkey waits until execution has finished

  if self.button_dispatch then
    coroutine.resume(self.exec, seconds)
    if coroutine.status(self.exec) == "dead" then self.button_dispatch = false end

  elseif self.hotkey_dispatch then
    if coroutine.status(self.exec) == "dead" then
      executor(self)
      self.hotkey_dispatch = false
    else
      coroutine.resume(self.exec, seconds)
    end

  elseif self.autorun and not self.button_dispatch then
    if self.preload then self.preload = false; executor(self) end
    coroutine.resume(self.exec, seconds)
  end

  for _, coro in pairs(self.tasks) do
    coroutine.resume(coro, seconds)
  end

  for _, i in pairs {"show", "hide", "activate", "deactivate"} do
    coroutine.resume(self["on_"..i.."_task"], seconds)
    if self["emit_"..i] and self["on_"..i.."_do"]
      and coroutine.status(self["on_"..i.."_task"]) == "dead" then -- blocking
      self["emit_"..i] = false
      self["on_"..i.."_do"]()
    end
  end
  -- poll for changes in global shared table for all console sources
  for name, num_code in pairs(SUB) do
    if num_code == _OFFER and self.pipe_name == name then
      self.actions_dispatch = true
      SUB[name] = 999
    elseif num_code == _STALL and self.pipe_name == name then
      self.is_action_paused = true
      SUB[name] = 999
    elseif num_code == _FORWARD and self.pipe_name == name then
      self.is_action_paused = false
      SUB[name] = 999
    elseif num_code == _SWITCH and self.pipe_name == name then
      self.is_action_paused = not self.is_action_paused
      SUB[name] = 999
    end
  end
  if self.actions_dispatch then
    executor(self, self.action_code, "exec_action_code", "actions entry")
    self.actions_dispatch = false
  end
  if not self.is_action_paused then
    coroutine.resume(self.exec_action_code, seconds)
  end

  coroutine.resume(self.external_py, seconds)

end

function SourceDef:get_properties()
  local props = obs_properties_create()
  obs_properties_add_text(props, "_text", "", OBS_TEXT_MULTILINE)
  obs_properties_add_button(props, "button1", "Execute!", function()
    self.button_dispatch = true
    executor(self)
  end)
  local s = "+   -  -  -  -  -  -  -  -  -  -  [ View output ] -  -  -  -  -  -  -  -  -  -    +"
  obs_properties_add_button(props, "button2", s, viewer)
  obs_properties_add_bool(props, "_autorun", "Auto run")
  obs_properties_add_text(props, "_action", "", OBS_TEXT_MULTILINE)

  local group_props = obs_properties_create()
  local _mv1, _mv2, _hotreload, _p1, _p2;
  _mv1 = obs_properties_add_float_slider(group_props, "_mv1", "Move value[0, 1] 0.01", 0, 1, 0.01)
  _mv2 = obs_properties_add_int_slider(group_props, "_mv2", "Move value[0, 100] 1", 0, 100, 1)
  _hotreload = obs_properties_add_text(group_props, "_hotreload", "Hot reload expression", OBS_TEXT_DEFAULT)
  _p1 = obs_properties_add_path(group_props, "_p1", "Path 1", OBS_PATH_FILE, "*.lua", script_path())
  _p2 = obs_properties_add_path(group_props, "_p2", "Path 2", OBS_PATH_FILE, "*.lua", script_path())
  obs_properties_add_group(props, "_group", "Settings for internal use", OBS_GROUP_NORMAL, group_props)

  return props
end

function SourceDef:show()
  self.emit_show = true -- going to preview
end

function SourceDef:hide()
  self.emit_hide = true -- hiding from preview
end

function SourceDef:activate()
  self.emit_activate = true -- going to program
end

function SourceDef:deactivate()
  self.emit_deactivate = true -- retiring from program 
end


function SourceDef:video_render(effect)
  local target = obs_filter_get_parent(self.filter)
  if target ~= nil then -- do not render, assign height & width to make scene item source selectable
    self.width = obs_source_get_base_width(target)
    self.height = obs_source_get_base_height(target)
  end
  obs_source_skip_video_filter(self.filter)
end

function SourceDef:get_width() return self.width end

function SourceDef:get_height() return self.height end

function SourceDef:get_name() return "Console" end

function SourceDef:load(settings) SourceDef._reg_htk(self, settings) end

function SourceDef:video_tick(seconds)
  if not self.loop_executor_timer then
    SourceDef._event_loop(self, seconds)
  end
  skip_tick_render(self) -- if source has crop or transform applied to it, this will let it render
end

function SourceDef:save(settings)
  if self.created_hotkeys then
    self.created_hotkeys = true
  end
  for k, v in pairs(self.hotkeys) do
    local a = obs_hotkey_save(self.hk[k])
    obs_data_set_array(settings, k, a)
    obs_data_array_release(a)
  end
end

function SourceDef:_reg_htk(settings)
  local parent = obs_filter_get_parent(self.filter)
  local source_name = obs_source_get_name(parent)
  local filter_name = obs_source_get_name(self.filter)
  if parent and source_name and filter_name then
    self.hotkeys["0;" .. source_name .. ";" .. filter_name] = function()
      self.hotkey_dispatch = true
    end
    self.hotkeys["1;" .. source_name .. ";" .. filter_name] = function(pressed)
      self.pressed = pressed
    end

    for k, v in pairs(self.hotkeys) do
      self.hk[k] = OBS_INVALID_HOTKEY_ID
    end

    for k, v in pairs(self.hotkeys) do
      if k:sub(1, 1) == "1" then -- starts with 1 symbol
        self.hk[k] = obs_hotkey_register_frontend(k, k, function(pressed)
          if pressed then
            self.hotkeys[k](true)
          else
            self.hotkeys[k](false)
          end
        end)
      else
        self.hk[k] = obs_hotkey_register_frontend(k, k, function(pressed)
          if pressed then
            self.hotkeys[k]()
          end
        end)
      end
      local a = obs_data_get_array(settings, k)
      obs_hotkey_load(self.hk[k], a)
      obs_data_array_release(a)
    end
    if not self.created_hotkeys then
      self.created_hotkeys = true
    end
  end
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

as_video_filter = SourceDef:new()
as_video_filter.id = "v_console_source"
as_video_filter.type = OBS_SOURCE_TYPE_FILTER
as_video_filter.output_flags = bit.bor(OBS_SOURCE_VIDEO)
obs_register_source(as_video_filter)

as_audio_filter = SourceDef:new()
as_audio_filter.id = "a_console_source"
as_audio_filter.type = OBS_SOURCE_TYPE_FILTER
as_audio_filter.output_flags = bit.bor(OBS_SOURCE_AUDIO)
obs_register_source(as_audio_filter)

as_audio_filter_timer, as_video_filter_timer = as_audio_filter, as_video_filter
as_video_filter_timer.id = "v_console_source_timer"
function as_video_filter_timer:get_name() return "Console (timer)" end 
obs_register_source(as_video_filter_timer)

as_audio_filter_timer.id = "a_console_source_timer"
function as_audio_filter_timer:get_name() return "Console (timer)" end 
obs_register_source(as_audio_filter_timer)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
as_custom_source = as_video_filter

function as_custom_source:get_name() return "AGPLv3+ obs-libre-macros by upgradeQ" end
function as_custom_source:video_render(settings) end
function as_custom_source:get_height() return 200 end
function as_custom_source:get_width() return 200 end
function as_custom_source:load(settings) as_custom_source._reg_htk(self, settings) end

function as_custom_source:update(settings)
  self.code = obs_data_get_string(settings, "_text")
  self.autorun = obs_data_get_bool(settings, "_autorun")
  self.mv1 = obs_data_get_double(settings, "_mv1")
  self.mv2 = obs_data_get_double(settings, "_mv2")
  self.hotreload = obs_data_get_string(settings, "_hotreload")
  self.p1 = obs_data_get_string(settings, "_p1")
  self.p2 = obs_data_get_string(settings, "_p2")
-- custom source logic for registering hotkeys
  if not self.created_hotkeys then
    as_custom_source._reg_htk(self, settings)
  end
end

function as_custom_source:_reg_htk(settings)
  -- note it's not a filter but rather a source itself
  local source_name = obs_source_get_name(self.filter)
  if source_name then
    self.hotkeys["2;" .. source_name] = function()
      self.hotkey_dispatch = true
    end
    self.hotkeys["3;" .. source_name] = function(pressed)
      self.pressed = pressed
    end

    for k, v in pairs(self.hotkeys) do
      self.hk[k] = OBS_INVALID_HOTKEY_ID
    end

    for k, v in pairs(self.hotkeys) do
      if k:sub(1, 1) == "3" then -- starts with 3 symbol
        self.hk[k] = obs_hotkey_register_frontend(k, k, function(pressed)
          if pressed then
            self.hotkeys[k](true)
          else
            self.hotkeys[k](false)
          end
        end)
      else
        self.hk[k] = obs_hotkey_register_frontend(k, k, function(pressed)
          if pressed then
            self.hotkeys[k]()
          end
        end)
      end
      local a = obs_data_get_array(settings, k)
      obs_hotkey_load(self.hk[k], a)
      obs_data_array_release(a)
    end
    if not self.created_hotkeys then
      self.created_hotkeys = true
    end
  end
end
as_custom_source.id = "s_console_source"
as_custom_source.type = OBS_SOURCE_TYPE_SOURCE
as_custom_source.output_flags = bit.bor(OBS_SOURCE_VIDEO, OBS_SOURCE_CUSTOM_DRAW, OBS_SOURCE_AUDIO)

obs_register_source(as_custom_source)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
-- id - obs keyboard id , c - character , cs - character with shift pressed
qwerty_minimal_keyboard_layout = {
  {id="OBS_KEY_BACKSPACE", c="backspace", cs="backspace"},
  {id="OBS_KEY_RETURN", c="enter", cs="enter"},
  {id="OBS_KEY_TAB", c="tab", cs="tab"},
  {id="OBS_KEY_ASCIITILDE", c="`", cs="~"},
  {id ="OBS_KEY_COMMA", c=", ", cs="<"},
  {id ="OBS_KEY_PLUS", c="=", cs="+"},
  {id ="OBS_KEY_MINUS", c="-", cs="_"},
  {id ="OBS_KEY_BRACKETLEFT", c="[", cs="{"},
  {id ="OBS_KEY_BRACKETRIGHT", c="]", cs="}"},
  {id ="OBS_KEY_PERIOD", c=".", cs=">"},
  {id ="OBS_KEY_APOSTROPHE", c="'", cs='"'},
  {id ="OBS_KEY_SEMICOLON", c=";", cs=":"},
  {id ="OBS_KEY_SLASH", c="/", cs="?"},
  {id ="OBS_KEY_SPACE", c=" ", cs=" "},
  {id ="OBS_KEY_0", c="0", cs=")"},
  {id ="OBS_KEY_1", c="1", cs="!"},
  {id ="OBS_KEY_2", c="2", cs="@"},
  {id ="OBS_KEY_3", c="3", cs="#"},
  {id ="OBS_KEY_4", c="4", cs="$"},
  {id ="OBS_KEY_5", c="5", cs="%"},
  {id ="OBS_KEY_6", c="6", cs="^"},
  {id ="OBS_KEY_7", c="7", cs="&"},
  {id ="OBS_KEY_8", c="8", cs="*"},
  {id ="OBS_KEY_9", c="9", cs="("},
  {id ="OBS_KEY_A", c="a", cs="A"},
  {id ="OBS_KEY_B", c="b", cs="B"},
  {id ="OBS_KEY_C", c="c", cs="C"},
  {id ="OBS_KEY_D", c="d", cs="D"},
  {id ="OBS_KEY_E", c="e", cs="E"},
  {id ="OBS_KEY_F", c="f", cs="F"},
  {id ="OBS_KEY_G", c="g", cs="G"},
  {id ="OBS_KEY_H", c="h", cs="H"},
  {id ="OBS_KEY_I", c="i", cs="I"},
  {id ="OBS_KEY_J", c="j", cs="J"},
  {id ="OBS_KEY_K", c="k", cs="K"},
  {id ="OBS_KEY_L", c="l", cs="L"},
  {id ="OBS_KEY_M", c="m", cs="M"},
  {id ="OBS_KEY_N", c="n", cs="N"},
  {id ="OBS_KEY_O", c="o", cs="O"},
  {id ="OBS_KEY_P", c="p", cs="P"},
  {id ="OBS_KEY_Q", c="q", cs="Q"},
  {id ="OBS_KEY_R", c="r", cs="R"},
  {id ="OBS_KEY_S", c="s", cs="S"},
  {id ="OBS_KEY_T", c="t", cs="T"},
  {id ="OBS_KEY_U", c="u", cs="U"},
  {id ="OBS_KEY_V", c="v", cs="V"},
  {id ="OBS_KEY_W", c="w", cs="W"},
  {id ="OBS_KEY_X", c="x", cs="X"},
  {id ="OBS_KEY_Y", c="y", cs="Y"},
  {id ="OBS_KEY_Z", c="z", cs="Z"},
}

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

function sname(source)
  return obs_source_get_name(source)
end

return_source_name = sname

function get_scene_sceneitem(scene_name, scene_item_name)
  local sceneitem;
  local scenes = obs_frontend_get_scenes()
  for _, scene in pairs(scenes) do
    if sname(scene) == scene_name then
      scene = obs_scene_from_source(scene)
      sceneitem = obs_scene_find_source_recursive(scene, scene_item_name)
    end
  end
  source_list_release(scenes)
  return sceneitem
end

function print_settings(source)
  local settings = obs_source_get_settings(source)
  local psettings = obs_source_get_private_settings(source)
  local dsettings = obs_data_get_defaults(settings); 
  local pdsettings = obs_data_get_defaults(psettings); 
  print("[---------- settings ----------")
  print(obs_data_get_json(settings))
  print("---------- private_settings ----------")
  print(obs_data_get_json(psettings))
  print("---------- default settings for this source type ----------")
  print(obs_data_get_json(dsettings))
  print("---------- default private settings for this source type ----------")
  print(obs_data_get_json(pdsettings))
  print(("----------%s----------]"):format(return_source_name(source)))
  for _, s in pairs { settings, psettings, dsettings, pdsettings}
    do obs_data_release(s) 
  end
end

function print_settings2(source, filter_name)
  local result = obs_source_enum_filters(source)
  for _, f in pairs(result) do
    if return_source_name(f) == filter_name then
      print_settings(f)
    end
  end
  source_list_release(result)
end

LMB, RMB, MOUSE_HOOKED = false, false, false
function htk_1_cb(pressed) LMB = pressed end
function htk_2_cb(pressed) RMB = pressed end
function hook_mouse_buttons()
  if MOUSE_HOOKED then return error('already hooked mouse') end
  local key_1 = '{"htk_1_mouse": [ { "key": "OBS_KEY_MOUSE1" } ], '
  local key_2 = '"htk_2_mouse": [ { "key": "OBS_KEY_MOUSE2" } ]}'
  local json_s = key_1 .. key_2
  local default_hotkeys = {
    {id='htk_1_mouse', des='LMB state', callback=htk_1_cb},
    {id='htk_2_mouse', des='RMB state', callback=htk_2_cb},
  }
  local s = obs_data_create_from_json(json_s)
  for _, v in pairs(default_hotkeys) do
    local a = obs_data_get_array(s, v.id)
    h = obs_hotkey_register_frontend(v.id, v.des, v.callback)
    obs_hotkey_load(h, a)
    obs_data_array_release(a)
  end
  obs_data_release(s)
  MOUSE_HOOKED = true
end

function get_modifiers(ctx)
  local key_modifiers = ctx or {}
  local shift = key_modifiers.shift or false
  local control = key_modifiers.control or false
  local alt = key_modifiers.alt or false
  local command = key_modifiers.command or false
  local modifiers = 0

  if shift then modifiers = bit.bor(modifiers, INTERACT_SHIFT_KEY ) end
  if control then modifiers = bit.bor(modifiers, INTERACT_CONTROL_KEY ) end
  if alt then modifiers = bit.bor(modifiers, INTERACT_ALT_KEY ) end
  if command then modifiers = bit.bor(modifiers, INTERACT_COMMAND_KEY ) end
  return modifiers
end

function send_hotkey(hotkey_id_name, key_modifiers)
  local combo = obs_key_combination()
  combo.modifiers = get_modifiers(key_modifiers)
  combo.key = obs_key_from_name(hotkey_id_name)

  if not modifiers and -- there is should be OBS_KEY_NONE, but it is missing in obslua
    (combo.key == 0 or combo.key >= OBS_KEY_LAST_VALUE) then
    return error('invalid key-modifier combination')
  end

  obs_hotkey_inject_event(combo, false)
  obs_hotkey_inject_event(combo, true)
  obs_hotkey_inject_event(combo, false)
end

function char_to_obskey(char)
  for _, row in pairs(qwerty_minimal_keyboard_layout) do
    if char == row.c or char == row.cs then
      return row.id
    end
  end
  error('character not found within qwerty minimal table')
end
c2o = char_to_obskey

function send_hotkey_tbs1(source, hotkey_id_name, key_up, key_modifiers)
  local key = obs_key_from_name(hotkey_id_name)
  local vk = obs_key_to_virtual_key(key)
  local event = obs_key_event()
  event.native_vkey = vk
  event.modifiers = get_modifiers(key_modifiers)
  event.native_modifiers = event.modifiers
  event.native_scancode = vk
  event.text = ""
  obs_source_send_key_click(source, event, key_up)
end

function send_hotkey_tbs2(source, char, key_up, key_modifiers)
  local event = obs_key_event()
  event.native_vkey = 0
  event.native_modifiers = 0
  event.native_scancode = 0
  event.modifiers = get_modifiers(key_modifiers)
  event.text = char
  obs_source_send_key_click(source, event, key_up)
end

function send_mouse_click_tbs(source, opts, key_modifiers)
  local event = obs_mouse_event()
  event.modifiers = get_modifiers(key_modifiers)
  event.x = opts.x
  event.y = opts.y
  obs_source_send_mouse_click(
    source, event, opts.button_type, opts.mouse_up, opts.click_count
    )
end

function send_mouse_move_tbs(source, x, y, key_modifiers)
  local event = obs_mouse_event()
  event.modifiers = get_modifiers(key_modifiers)
  event.x = x
  event.y = y
  obs_source_send_mouse_move(source, event, false) -- do not leave
end

function send_mouse_wheel_tbs(source, x, y, x_delta, y_delta, key_modifiers)
  local event = obs_mouse_event()
  event.x = opts.x or 0
  event.y = opts.y or 0
  event.modifiers = get_modifiers(key_modifiers)
  local x_delta = opts.x_delta or 0
  local y_delta = opts.y_delta or 0
  obs_source_send_mouse_wheel(source, event, x_delta, y_delta)
end


ffi.cdef[[
typedef struct obs_hotkey obs_hotkey_t;
typedef size_t obs_hotkey_id;

const char *obs_hotkey_get_name(const obs_hotkey_t *key);
typedef bool (*obs_hotkey_enum_func)(void *data, obs_hotkey_id id, obs_hotkey_t *key);
void obs_enum_hotkeys(obs_hotkey_enum_func func, void *data);
]]

function trigger_from_hotkey_callback(description)
  local htk_id;
  function callback_htk(data, id, key)
    local name = obsffi.obs_hotkey_get_name(key)
    if ffi.string(name) == description then
      htk_id = tonumber(id)
      return false
    else
      return true
    end
  end
  local cb = ffi.cast("obs_hotkey_enum_func", callback_htk)
  obsffi.obs_enum_hotkeys(cb, nil)
  if htk_id then
    obs_hotkey_trigger_routed_callback(htk_id, false)
    obs_hotkey_trigger_routed_callback(htk_id, true)
    obs_hotkey_trigger_routed_callback(htk_id, false)
  end
end

ffi.cdef[[
typedef struct obs_source obs_source_t;
obs_source_t *obs_get_source_by_name(const char *name);
void obs_source_release(obs_source_t *source);

enum obs_fader_type {
  OBS_FADER_CUBIC,
  OBS_FADER_IEC,
  OBS_FADER_LOG
};

typedef struct obs_volmeter obs_volmeter_t;

bool obs_volmeter_attach_source(obs_volmeter_t *volmeter,
               obs_source_t *source);

int MAX_AUDIO_CHANNELS;

obs_volmeter_t *obs_volmeter_create(enum obs_fader_type type);

typedef void (*obs_volmeter_updated_t)(
  void *param, const float magnitude[MAX_AUDIO_CHANNELS],
  const float peak[MAX_AUDIO_CHANNELS],
  const float input_peak[MAX_AUDIO_CHANNELS]);

void obs_volmeter_add_callback(obs_volmeter_t *volmeter,
              obs_volmeter_updated_t callback,
              void *param);

void obs_volmeter_set_peak_meter_type(obs_volmeter_t *volmeter,
              enum obs_peak_meter_type peak_meter_type);
]]

LVL, NOISE, LOCK = "?", 0, false
function callback_meter(data, mag, peak, input)
  LVL = 'Volume lvl is :' .. tostring(tonumber(peak[0]))
  NOISE = tonumber(peak[0])
end


jit.off(callback_meter)

function volume_level(source_name)
  if LOCK then return error("cannot attach to more than 1 source") end
  local source = obsffi.obs_get_source_by_name(source_name)
  local volmeter = obsffi.obs_volmeter_create(obsffi.OBS_FADER_LOG)
  -- https://github.com/WarmUpTill/SceneSwitcher/blob/214821b69f5ade803a4919dc9386f6351583faca/src/switch-audio.cpp#L194-L207
  local cb = ffi.cast("obs_volmeter_updated_t", callback_meter)
  obsffi.obs_volmeter_add_callback(volmeter, cb, nil)
  obsffi.obs_volmeter_attach_source(volmeter, source)
  obsffi.obs_source_release(source)
  LOCK = true
end

function read_private_data(data_type, field)
  local s = obs_get_private_data()
  local result = _G[("obs_data_get_%s"):format(data_type)](s, field)
  obs_data_release(s)
  return result
end

function write_private_data(data_type, field, result)
  local s = obs_data_create()
  _G[("obs_data_set_%s"):format(data_type)](s, field, result)
  obs_apply_private_data(s)
  obs_data_release(s)
end

function exec_py(string_, address)
  local handshake;
  if not address then 
    handshake = "__py_dispatch"
    address = "__py_registry"
  else 
    handshake = ("__py_dispatch%s"):format(address)
    address = ("__py_registry%s"):format(address)
  end
  local s = obs_data_create()
  obs_data_set_string(s, address, string_)
  obs_data_set_bool(s, handshake, true)
  obs_apply_private_data(s)
  obs_data_release(s)
end

----------------usage
-- exec_py(
-- [=[def print_hello():
     -- print('hello world')
     -- a = [ x for x in range(10) ][0]
     -- return a
-- print_hello()
-- ]=])
---------------------

function get_code(address)
  local handshake;
  if not address then 
    handshake = "__lua_dispatch"
    address = "__lua_registry"
  else 
    handshake = ("__lua_dispatch%s"):format(address)
    address = ("__lua_registry%s"):format(address)
  end
  local s = obs_get_private_data()
  local string_ = obs_data_get_string(s, address)
  local proceed = obs_data_get_bool(s, handshake)
  obs_data_release(s)
  return proceed, string_, handshake
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
--
CODE_STORAGE = [===[
local t = __t; 
local source = t.source

function print_source_name(source)
  print(obs_source_get_name(source))
end

local function execute_from_private_registry(address, tickrate)
  tickrate = tickrate or 1/60
  while true do
    proceed, code, handshake = get_code(address)
    sleep(tickrate)
    if proceed then
      executor(t, code, "external_py", "python_receiver")
      write_private_data("bool", handshake, false)
    end
  end
end

local function accept(address, tickrate)
  execute_from_private_registry(address, tickrate)
end


local function register_on_show(delayed_callback)
  t.on_show_do = function()
    t.on_show_task = run(function() delayed_callback() end) 
  end
end

local function register_on_hide(delayed_callback)
  t.on_hide_do = function()
    t.on_hide_task = run(function() delayed_callback() end) 
  end
end

local function register_on_activate(delayed_callback)
  t.on_activate_do = function()
    t.on_activate_task = run(function() delayed_callback() end) 
  end
end

local function register_on_deactivate(delayed_callback)
  t.on_deactivate_do = function()
    t.on_deactivate_task = run(function() delayed_callback() end) 
  end
end

local function okay(name) t.pipe_name = name end

-- leave empty new line with 2 spaces
  
]===]

-- vim: ft=lua ts=2 sw=2 et sts=2
