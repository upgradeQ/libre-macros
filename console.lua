copyleft = [[
obs-libre-macros - scripting and macros hotkeys in OBS Studio for Humans
Contact/URL https://www.github.com/upgradeQ/obs-libre-macros
Copyright (C) 2021-2022 upgradeQ

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
obs_libre_macros_versions = "OBS 27.2.4 64bit Windows 11 extension version 3.0.0"

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
-- https://stackoverflow.com/a/8891620 by kikito
local i18n = { locales = {} }

local current_locale = 'en' -- the default language

function i18n.set_locale(new_locale)
  current_locale = new_locale
  assert(i18n.locales[current_locale], ("The locale %q was unknown"):format(new_locale))
end

local function translate(id)
  local result = i18n.locales[current_locale][id]
  assert(result, ("The id %q was not found in the current locale (%q)"):format(id, current_locale))
  return result
end

i18n.translate = translate

setmetatable(i18n, {__call = function(_, ...) return translate(...) end})

i18n.locales.en = {
  select_lang = 'Select language',
  execute = 'Execute!',
  view_output = 'View output',
  auto_run = 'Auto run',
  s_mv1 = 'Move value variable[0, 1] 0.01',
  s_mv2 = 'Move value variable[0, 100] 1',
  hotreload = 'Hot reload expression',
  p1 = 'Path 1',
  p2 = 'Path 2',
  p_group_name = 'Settings for interval use, text area above is for global multi action pipes',
  width = 'Width',
  height = 'Height',
  g2_restart = 'Restart required to enable/disable this sources',
  ['Console (Timer)'] = 'Console (Timer)',
  ['Console sceneitem custom'] = 'Console sceneitem custom',
  ['Gap source'] = 'Gap source',
  ['Console'] = 'Console',
  interval = 'Timer interval per second',
}

i18n.locales.ru = {
  select_lang = 'Выбрать язык',
  execute = 'Выполнить!',
  view_output = 'Посмотреть результат',
  auto_run = 'Запускать автоматически',
  s_mv1 = 'Перменная движения[0, 1] 0.01',
  s_mv2 = 'Перменная движения[0, 100] 1',
  hotreload = 'Выполнять выражение автоматически',
  p1 = 'Путь 1',
  p2 = 'Путь 2',
  p_group_name = 'Внутренние настройки, поле текста выше для глобальных мульти последовательностей',
  width = 'Ширина',
  height = 'Высота',
  g2_restart = 'Требуется перезапуск что вкл/выкл эти источники',
  ['Console (Timer)'] = 'Консоль (Таймер)',
  ['Console sceneitem custom'] = 'Консоль специальный предмет сцены',
  ['Gap source'] = 'Пустой источник',
  ['Console'] = 'Консоль',
  interval = 'Интервал таймера раз в секунду',
}
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
local function open_package(ns)
  for n, v in pairs(ns) do _G[n] = v end
end

open_package(obslua)
ffi = require "ffi" -- for native libs and C code access
jit = require "jit" -- for C thread callback behavior change
bit = require "bit" -- binary logic

local function try_load_library(alias, name)
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
SUB = {} -- {{"pipe_name": num_code}, ...}

_OFFER = 111;function offer(pipe_name) SUB[pipe_name] = _OFFER end
_STALL = 222;function stall(pipe_name) SUB[pipe_name] = _STALL end
_FORWARD = 333;function forward(pipe_name) SUB[pipe_name] = _FORWARD end
_SWITCH = 444;function switch(pipe_name) SUB[pipe_name] = _SWITCH end
_RECOMPILE = 555;function recompile(pipe_name) SUB[pipe_name] = _RECOMPILE end

local function executor(ctx, code, loc, name) -- args defined automatically  as local
  local custom_env52  = {}
  setmetatable(custom_env52, {__index = _G})
  custom_env52.source = obs_filter_get_parent(ctx.filter)
  loc = loc or "exec" -- special locaition address if python sript is present
  name = name or "obs repl"
  custom_env52.t = ctx
  code = code or custom_env52.t.code
  for k,v in pairs(utils) do custom_env52[k] = setfenv(v,custom_env52) end
  local exec = assert(load(CODE_STORAGE_INIT .. code, name, "t", custom_env52))
  -- executor submits code to event loop, which will execute it with .resume
  ctx[loc] = run(exec)
end

local function skip_tick_render(ctx)
  local target = obs_filter_get_target(ctx.filter)
  local width, height;
  if target == nil then width = 0; height = 0; else
    width = obs_source_get_base_width(target)
    height = obs_source_get_base_height(target)
  end
  ctx.width, ctx.height = width , height
end

local function viewer()
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
  local value = SourceDef.__interval
  local ms = (1/value) * 1000; ms = ms + (2^52 + 2^51) - (2^52 + 2^51) 
  local interval = 1/value 
  timer_add(function() SourceDef._event_loop(self, interval) end, ms)
  self.loop_executor_timer = true
end

function SourceDef:create(source)
  local instance = {}
  instance.filter = source -- filter source itself
  instance.hotkeys = {}
  instance.hk = {}
  instance.pressed = false
  instance.pressed2 = false
  instance.pressed3 = false
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
    elseif num_code == _RECOMPILE and self.pipe_name == name then
      executor(self, self.action_code, "exec_action_code", "actions entry recompiled")
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
  obs_properties_add_button(props, "button1", i18n"execute", function()
    self.button_dispatch = true
    executor(self)
  end)
  local s = "+   -  -  -  -  -  -  -  -  -  -  [ " .. i18n"view_output"
  .. " ] -  -  -  -  -  -  -  -  -  -    +"
  obs_properties_add_button(props, "button2", s, viewer)
  obs_properties_add_bool(props, "_autorun", i18n"auto_run")
  obs_properties_add_text(props, "_action", "", OBS_TEXT_MULTILINE)

  local group_props = obs_properties_create()
  local _mv1, _mv2, _hotreload, _p1, _p2;
  _mv1 = obs_properties_add_float_slider(group_props, "_mv1", i18n"s_mv1", 0, 1, 0.01)
  _mv2 = obs_properties_add_int_slider(group_props, "_mv2", i18n"s_mv2", 0, 100, 1)
  _hotreload = obs_properties_add_text(group_props, "_hotreload", i18n"hotreload", OBS_TEXT_DEFAULT)
  _p1 = obs_properties_add_path(group_props, "_p1", i18n"p1", OBS_PATH_FILE, "*.lua", script_path())
  _p2 = obs_properties_add_path(group_props, "_p2", i18n"p2", OBS_PATH_FILE, "*.lua", script_path())
  obs_properties_add_group(props, "_group", i18n"p_group_name", OBS_GROUP_NORMAL, group_props)

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

function SourceDef:get_name() return i18n"Console" end

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
    self.hotkeys["2;" .. source_name .. ";" .. filter_name] = function(pressed)
      self.pressed2 = pressed
    end
    self.hotkeys["3;" .. source_name .. ";" .. filter_name] = function(pressed)
      self.pressed3 = pressed
    end

    for k, v in pairs(self.hotkeys) do
      self.hk[k] = OBS_INVALID_HOTKEY_ID
    end

    function reroute_hotkey_state(k)
      self.hk[k] = obs_hotkey_register_frontend(k, k, function(pressed)
        if pressed then
          self.hotkeys[k](true)
        else
          self.hotkeys[k](false)
        end
      end)
    end

    for k, v in pairs(self.hotkeys) do
      if k:sub(1, 1) == "1" then -- starts with 1 symbol
        reroute_hotkey_state(k)
      elseif k:sub(1, 1) == "2" then 
        reroute_hotkey_state(k)
      elseif k:sub(1, 1) == "3" then 
        reroute_hotkey_state(k)
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
as_custom_source = SourceDef:new({
  id = "s_console_source",
  type = OBS_SOURCE_TYPE_SOURCE,
  output_flags = bit.bor(OBS_SOURCE_VIDEO, OBS_SOURCE_CUSTOM_DRAW, OBS_SOURCE_AUDIO),
})
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

as_gap_source = {}
function as_gap_source:create(source) 
  local instance = {}
  as_gap_source.update(instance, self) -- self = settings and this shows it on screen
  return instance
end
function as_gap_source:get_name() return i18n"Gap source" end
function as_gap_source:update(settings) 
  self.height = obs_data_get_double(settings, "_height")
  self.width = obs_data_get_double(settings, "_width")
end
function as_gap_source:get_properties()
  local props = obs_properties_create()
  obs_properties_add_int_slider(props, "_width", i18n"width", 1, 9999, 1)
  obs_properties_add_int_slider(props, "_height", i18n"height", 1, 9999, 1)
  return props
end
function as_gap_source:load(settings)
  self.height = obs_data_get_double(settings, "_height")
  self.width = obs_data_get_double(settings, "_width")
end
function as_gap_source:get_height() return self.height end
function as_gap_source:get_width() return self.width end
as_gap_source.id = "_gap_source"
as_gap_source.type = OBS_SOURCE_TYPE_SOURCE
as_gap_source.output_flags = bit.bor(OBS_SOURCE_VIDEO, OBS_SOURCE_CUSTOM_DRAW)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
function script_description()
  return copyleft:sub(1, 168) .. '\nTested on: ' .. obs_libre_macros_versions ..
  '\nReleased under GNU Affero General Public License, AGPLv3+'
end

function script_properties()
  local props = obs_properties_create()
  local props_group1 = obs_properties_create()
  obs_properties_add_bool(props_group1, "_flag_custom", i18n"Console sceneitem custom")
  obs_properties_add_bool(props_group1, "_flag_gap", i18n"Gap source")
  obs_properties_add_bool(props_group1, "_flag_console_timer", i18n"Console (Timer)")
  obs_properties_add_float(props_group1, "_interval",i18n"interval",0,999,0.001)
  obs_properties_add_group(props, "group1", i18n"g2_restart", OBS_GROUP_NORMAL, props_group1)
  local _langs = obs_properties_add_list(props, "_lang", i18n"select_lang", OBS_COMBO_TYPE_LIST, OBS_COMBO_FORMAT_STRING)

  for k, v in pairs {en="English", ru="Русский"} do
    obs_property_list_add_string(_langs, v, k)
  end

  return props
end

function script_defaults(settings)
  obs_data_set_default_string(settings, "_lang", "en")
  obs_data_set_default_double(settings, "_interval",60)
end

function script_load(settings)
  i18n.set_locale(obs_data_get_string(settings, "_lang")) -- must load first
  local as_video_filter = SourceDef:new({id = "v_console_source", type = OBS_SOURCE_TYPE_FILTER, output_flags = bit.bor(OBS_SOURCE_VIDEO),})
  obs_register_source(as_video_filter)

  local as_audio_filter = SourceDef:new({ id = "a_console_source", type = OBS_SOURCE_TYPE_FILTER, output_flags = bit.bor(OBS_SOURCE_AUDIO),})
  obs_register_source(as_audio_filter)


  if obs_data_get_bool(settings, "_flag_gap") then
    obs_register_source(as_gap_source) 
  end
  if obs_data_get_bool(settings, "_flag_custom") then
    obs_register_source(as_custom_source) 
  end
  if obs_data_get_bool(settings, "_flag_console_timer") then
    local interval = obs_data_get_double(settings, "_interval")
    local as_audio_filter_timer, as_video_filter_timer = as_audio_filter, as_video_filter
    as_video_filter_timer.id = "v_console_source_timer"
    SourceDef.__interval = interval
    function as_video_filter_timer:get_name() return i18n"Console (Timer)" end 

    as_audio_filter_timer.id = "a_console_source_timer"
    SourceDef.__interval = interval
    function as_audio_filter_timer:get_name() return i18n"Console (Timer)" end 
    obs_register_source(as_video_filter_timer)
    obs_register_source(as_audio_filter_timer)
  end
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
-- global general purpose functions -  preloaded

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


function set_settings2(source, filter_name, opts)
  local result = obs_source_enum_filters(source)
  local settings = obs_data_create()
  for _, f in pairs(result) do
    if return_source_name(f) == filter_name then
      _G[("obs_data_set_%s"):format(opts._type)](settings, opts._field, opts._value)
      obs_source_update(f, settings)
      obs_data_release(settings)
    end
  end
  source_list_release(result)
end

function set_settings3(source, filter_name, json_string)
  local result = obs_source_enum_filters(source)
  local settings = obs_data_create_from_json(json_string)
  for _, f in pairs(result) do
    if return_source_name(f) == filter_name then
      obs_source_update(f, settings)
      obs_data_release(settings)
    end
  end
  source_list_release(result)
end

function set_settings4(source, json_string)
  local settings = obs_data_create_from_json(json_string)
  obs_source_update(f, settings)
  obs_data_release(settings)
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
-- https://stackoverflow.com/a/61269226 by Egor-Skriptunoff
if ffi.os == 'Windows' then 
ffi.cdef[[
typedef struct _STARTUPINFOA {
  uint32_t  cb;
  void *    lpReserved;
  void *    lpDesktop;
  void *    lpTitle;
  uint32_t  dwX;
  uint32_t  dwY;
  uint32_t  dwXSize;
  uint32_t  dwYSize;
  uint32_t  dwXCountChars;
  uint32_t  dwYCountChars;
  uint32_t  dwFillAttribute;
  uint32_t  dwFlags;
  uint16_t  wShowWindow;
  uint16_t  cbReserved2;
  void *    lpReserved2;
  void **   hStdInput;
  void **   hStdOutput;
  void **   hStdError;
} STARTUPINFOA, *LPSTARTUPINFOA;
typedef struct _PROCESS_INFORMATION {
  void **  hProcess;
  void **  hThread;
  uint32_t dwProcessId;
  uint32_t dwThreadId;
} PROCESS_INFORMATION, *LPPROCESS_INFORMATION;
uint32_t CreateProcessA(
  void *,
  const char * commandLine,
  void *,
  void *,
  uint32_t,
  uint32_t,
  void *,
  const char * currentDirectory,
  LPSTARTUPINFOA,
  LPPROCESS_INFORMATION
);
uint32_t CloseHandle(void **);
]]

function execute(command_line, current_directory)
   local si = ffi.new"STARTUPINFOA"
   si.cb = ffi.sizeof(si)
   si.lpReserved = nil;
   si.lpDesktop = nil;
   si.lpTitle = nil;
   si.dwFlags = 1; -- STARTF_USESHOWWINDOW
   si.wShowWindow = 0; -- SW_HIDE 
   si.cbReserved2 = 0; -- must be zero
   si.lpReserved2 = nil
   local pi = ffi.new"PROCESS_INFORMATION"
   local ok = ffi.C.CreateProcessA(nil, command_line, nil, nil, 0, 0, nil, current_directory, si, pi) ~= 0
   if ok then
      ffi.C.CloseHandle(pi.hProcess)
      ffi.C.CloseHandle(pi.hThread)
   end
   return ok  -- true/false
end
end

function print_source_name(source)
  print(obs_source_get_name(source))
end

-- setfenv functions with nonlocal variable t(instance)
utils = {}

function utils.okay(name) t.pipe_name = name end

function utils.execute_from_private_registry(address, tickrate)
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

function utils.accept(address, tickrate)
  execute_from_private_registry(address, tickrate)
end

function utils.register_on_show(delayed_callback)
  t.on_show_do = function()
    t.on_show_task = run(function() delayed_callback() end) 
  end
end

function utils.register_on_hide(delayed_callback)
  t.on_hide_do = function()
    t.on_hide_task = run(function() delayed_callback() end) 
  end
end

function utils.register_on_activate(delayed_callback)
  t.on_activate_do = function()
    t.on_activate_task = run(function() delayed_callback() end) 
  end
end

function utils.register_on_deactivate(delayed_callback)
  t.on_deactivate_do = function()
    t.on_deactivate_task = run(function() delayed_callback() end) 
  end
end

function utils.get_gap_source(opts)
  local gap, settings;
  local w = opts.w 
  local h = opts.h 
  local n = opts.n
  settings = obs_data_create()
  obs_data_set_double(settings, "_width", w)
  obs_data_set_double(settings, "_height", h)
  gap = obs_source_create("_gap_source", n, settings, nil)
  return gap, settings
end

function utils.__c(source, settings)
  -- clear current context
  obs_source_release(source)
  obs_data_release(settings)
end

function utils.add_outer_gap(size)
  size = size or 15
  if not t.__scene then  -- otherwise its crashes
    t.__scene = obs_scene_from_source(source)
  end
  local width = obs_source_get_base_width(source)
  local height = obs_source_get_base_height(source)

  local rgap, rsettings = get_gap_source({w=size, h=height, n="_right_gap"});
  local lgap, lsettings = get_gap_source({w=size, h=height, n="_left_gap"});
  local ugap, usettings = get_gap_source({w=width, h=size, n="_up_gap"});
  local dgap, dsettings = get_gap_source({w=width, h=size, n="_down_gap"});
  local rpos, lpos, upos, dpos = vec2(), vec2(), vec2(), vec2()
  local r = obs_scene_add(t.__scene, rgap); __c(rgap, rsettings)
  local l = obs_scene_add(t.__scene, lgap); __c(lgap, lsettings)
  local u = obs_scene_add(t.__scene, ugap); __c(ugap, usettings)
  local d = obs_scene_add(t.__scene, dgap); __c(dgap, dsettings)
  lpos.x, lpos.y = 0, 0; obs_sceneitem_set_pos(l, lpos)
  rpos.x, rpos.y = width - size, 0; obs_sceneitem_set_pos(r, rpos)
  upos.x, upos.y = 0, 0; obs_sceneitem_set_pos(u, upos)
  dpos.x, dpos.y = 0, height - size; obs_sceneitem_set_pos(d, dpos)
end

function utils.delete_all_gaps()
  if not t.__scene then  -- otherwise its crashes
    t.__scene = obs_scene_from_source(source)
  end
  local items = obs_scene_enum_items(t.__scene)
  for _, i in pairs(items) do 
    if obs_source_get_unversioned_id(obs_sceneitem_get_source(i)) == '_gap_source' then
      obs_sceneitem_remove(i)
    end
  end
  sceneitem_list_release(items)
end

function utils._update_gap_base(gs, opts)
  local settings = obs_source_get_settings(gs)
  obs_data_set_double(settings, "_width", opts.w)
  obs_data_set_double(settings, "_height", opts.h)
  obs_source_update(gs, settings)
  obs_data_release(settings)
end

function utils._set_gap(gs, gi, size, width, height)
  local pos = vec2()
  local name = obs_source_get_name(gs)

  if name == '_right_gap' then
    _update_gap_base(gs, {w = size, h = height})
    pos.x, pos.y = width - size, 0; obs_sceneitem_set_pos(gi, pos)
  elseif name =='_left_gap' then
    _update_gap_base(gs, {w = size, h = height})
    pos.x, pos.y = 0, 0; obs_sceneitem_set_pos(gi, pos)
  elseif name =='_up_gap' then
    _update_gap_base(gs, {w = width, h = size})
    pos.x, pos.y = 0, 0; obs_sceneitem_set_pos(gi, pos)
  elseif name =='_down_gap' then
    _update_gap_base(gs, {w = width, h = size})
    pos.x, pos.y = 0, height - size; obs_sceneitem_set_pos(gi, pos)
  end
end

function utils.resize_outer_gaps(size)
  size = size or 15
  if not t.__scene then  -- otherwise its crashes
    t.__scene = obs_scene_from_source(source)
  end
  local items = obs_scene_enum_items(t.__scene)
  local width = obs_source_get_base_width(source)
  local height = obs_source_get_base_height(source)
  for _, i in pairs(items) do 
    local s = obs_sceneitem_get_source(i)
    if obs_source_get_unversioned_id(s) == '_gap_source' then
      _set_gap(s, i, size, width, height)
    end
  end
  sceneitem_list_release(items)
end

function utils.add_gap(opts)
  -- add_gap {x=300,y=500, width = 100, height = 100}
  if not t.__scene then  -- otherwise its crashes
    t.__scene = obs_scene_from_source(source)
  end
  local gap,settings = get_gap_source({w=opts.width, h=opts.height, n="_unnamed_gap"});
  local item = obs_scene_add(t.__scene, gap); __c(gap, settings)
  local pos = vec2(); pos.x, pos.y = opts.x, opts.y
  obs_sceneitem_set_pos(item, pos)
end

CODE_STORAGE_INIT = [===[

-- leave empty new line with 2 spaces, there might be bootstraping and initialization code here
  
]===]

-- vim: ft=lua ts=2 sw=2 et sts=2
