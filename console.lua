copyright = [[
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
print(copyright)
obs_libre_macros_version = "0.1.0"
obs = obslua -- needs to be global for use in repl
ffi = require "ffi"

if ffi.os == "OSX" then
  obsffi = ffi.load("obs.0.dylib")
else
  obsffi = ffi.load("obs")
end


run = coroutine.create
gn = {}

local Timer = {}
function Timer:init(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  return o
end

function Timer:update(dt)
  self.current_time = self.current_time + dt
  if self.current_time >= self.delay then
    self.finished = true
  end
end

function Timer:enter()
  self.finished = false
  self.current_time = 0
end

function Timer:launch()
  self:enter()
  while not self.finished do
    local dt = coroutine.yield()
    self:update(dt)
  end
end

function sleep(s)
  local action = Timer:init{delay=s}
  action:launch()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

function executor(data_settings_namespace)
  local _ENV = _G
  _ENV["__t"] = data_settings_namespace
  _ENV.__t.source = obs.obs_filter_get_parent(data_settings_namespace.filter)
  local exec = assert(load("local t = __t; " .. _ENV.__t.code,"obs repl","t"))
  data_settings_namespace.exec = run(exec)
end

function skip_tick_render(_context)
  local target = obs.obs_filter_get_target(_context.filter)
  local width, height;
  if target == nil then width = 0; height = 0; else
    width = obs.obs_source_get_base_width(target)
    height = obs.obs_source_get_base_height(target)
  end
  _context.width, _context.height = width , height
end

function viewer()
  error(">Script Log")
end

function print_source_name(source)
  print(obs.obs_source_get_name(source))
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

local SourceDef = {}

function SourceDef:init(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  return o 
end

function SourceDef:create(source)
  local instance = {}
  instance.hotkeys = {}
  instance.hk = {}
  instance.pressed = false
  instance.button_dispatch = false
  instance.auto_dispatch = true
  instance.hotkey_dispatch = false
  instance.created_hotkeys = false
  instance.tasks = {}
  instance.filter = source -- filter source itself
  instance.exec = run(function() coroutine.yield() end)
  SourceDef.update(instance,self)
  return instance
end

function SourceDef:get_width()
  return self.width
end

function SourceDef:get_height()
  return self.height 
end

function SourceDef:get_name()
  return "Console"
end

function SourceDef:video_render(effect) 
  local target = obs.obs_filter_get_parent(self.filter)
  if target ~= nil then -- do not render, assign height & width to make scene item source selectable 
    self.width = obs.obs_source_get_base_width(target)
    self.height = obs.obs_source_get_base_height(target)
  end
  obs.obs_source_skip_video_filter(self.filter) 
end

function SourceDef:load(settings)
  SourceDef.reg_htk(self,settings)
end

function SourceDef:update(settings)
  self.code = obs.obs_data_get_string(settings,"_text")
  self.autorun = obs.obs_data_get_bool(settings,"_autorun")
  self.mv1 = obs.obs_data_get_double(settings,"_mv1")
  self.mv2 = obs.obs_data_get_double(settings,"_mv2")
  self.hotreload = obs.obs_data_get_string(settings,"_hotreload")
  self.p1 = obs.obs_data_get_string(settings,"_p1")
  self.p2 = obs.obs_data_get_string(settings,"_p2")

  if not self.created_hotkeys then
    SourceDef.reg_htk(self,settings)
  end
end

function SourceDef:save(settings)
  if self.created_hotkeys then
    self.created_hotkeys = true
  end
  for k, v in pairs(self.hotkeys) do
    local a = obs.obs_hotkey_save(self.hk[k])
    obs.obs_data_set_array(settings, k, a)
    obs.obs_data_array_release(a)
  end
end

function SourceDef:reg_htk(settings)
  local parent = obs.obs_filter_get_parent(self.filter)
  local source_name = obs.obs_source_get_name(parent)
  local filter_name = obs.obs_source_get_name(self.filter)
  if parent and source_name and filter_name then
    self.hotkeys["0;" .. source_name .. ";" .. filter_name] = function()
      self.hotkey_dispatch = true
    end
    self.hotkeys["1;" .. source_name .. ";" .. filter_name] = function(pressed)
      self.pressed = pressed
    end

    for k,v in pairs(self.hotkeys) do 
      self.hk[k] = obs.OBS_INVALID_HOTKEY_ID
    end

    for k, v in pairs(self.hotkeys) do 
      if k:sub(1,1) == "1" then -- starts with 1 symbol 
        self.hk[k] = obs.obs_hotkey_register_frontend(k, k, function(pressed)
          if pressed then 
            self.hotkeys[k](true)
          else
            self.hotkeys[k](false)
          end
        end)
      else
        self.hk[k] = obs.obs_hotkey_register_frontend(k, k, function(pressed)
          if pressed then 
            self.hotkeys[k]() 
          end 
        end)
      end
      local a = obs.obs_data_get_array(settings, k)
      obs.obs_hotkey_load(self.hk[k], a)
      obs.obs_data_array_release(a)
    end
    if not self.created_hotkeys then 
      self.created_hotkeys = true
    end
  end
end

function SourceDef:get_properties()
  local props = obs.obs_properties_create()
  obs.obs_properties_add_text(props, "_text", "", obs.OBS_TEXT_MULTILINE)
  obs.obs_properties_add_button(props, "button1", "Execute!",function()
    self.button_dispatch = true
    executor(self)
  end)
  local s = "+   -  -  -  -  -  -  -  -  -  -  [ View output ] -  -  -  -  -  -  -  -  -  -    +"
  obs.obs_properties_add_button(props, "button2",s,viewer)
  obs.obs_properties_add_bool(props,"_autorun","Auto run")

  local group_props = obs.obs_properties_create()
  local _mv1,_mv2,_hotreload,_p1,_p2;
  _mv1 = obs.obs_properties_add_float_slider(group_props, "_mv1","Move value[0,1] 0.01", 0, 1, 0.01)
  _mv2 = obs.obs_properties_add_int_slider(group_props, "_mv2","Move value[0,100] 1", 0, 100, 1)
  _hotreload = obs.obs_properties_add_text(group_props, "_hotreload", "Hot reload expression", obs.OBS_TEXT_DEFAULT)
  _p1 = obs.obs_properties_add_path(group_props,"_p1","Path 1",obs.OBS_PATH_FILE,"*.lua",script_path())
  _p2 = obs.obs_properties_add_path(group_props,"_p2","Path 2",obs.OBS_PATH_FILE,"*.lua",script_path())
  obs.obs_properties_add_group(props,"_group","Settings for internal use",obs.OBS_GROUP_NORMAL,group_props)

  return props
end

function SourceDef:video_tick(seconds)

  if self.button_dispatch then -- execute code just once
    coroutine.resume(self.exec,seconds)
    if coroutine.status(self.exec) == "dead" then 
      self.button_dispatch = false
    end
  end

  if self.hotkey_dispatch  then
    executor(self)
    self.hotkey_dispatch = false
    self.button_dispatch = true
  end

  if self.auto_dispatch then  
    executor(self)
    self.auto_dispatch = false
  end


  if self.autorun and not self.button_dispatch then
    coroutine.resume(self.exec,seconds) 
  end


  for _,coro in pairs(self.tasks) do
    coroutine.resume(coro,seconds)
  end

  skip_tick_render(self) -- if source has crop or transform applied to it, this will let it render
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

as_video_filter = SourceDef:init()
as_video_filter.id = "v_console_source"
as_video_filter.type = obs.OBS_SOURCE_TYPE_FILTER
as_video_filter.output_flags = bit.bor(obs.OBS_SOURCE_VIDEO)

obs.obs_register_source(as_video_filter)

as_audio_filter = SourceDef:init()
as_audio_filter.id = "a_console_source"
as_audio_filter.type = obs.OBS_SOURCE_TYPE_FILTER
as_audio_filter.output_flags = bit.bor(obs.OBS_SOURCE_AUDIO)

obs.obs_register_source(as_audio_filter)

as_custom_source = SourceDef:init()
function as_custom_source:get_name() return "AGPLv3+ obs-libre-macros by upgradeQ" end
function as_custom_source:create(settings) local data = {}; return data end
function as_custom_source:video_tick(settings) end
function as_custom_source:video_render(settings) end
function as_custom_source:get_height() return 0 end
function as_custom_source:get_width() return 0 end
function as_custom_source:get_properties() end
function as_custom_source:update(settings) end
function as_custom_source:load(settings) end
function as_custom_source:save(settings) end
as_custom_source.id = "s_console_source"
as_custom_source.type = obs.OBS_SOURCE_TYPE_SOURCE
as_custom_source.output_flags = bit.bor(obs.OBS_SOURCE_VIDEO,obs.OBS_SOURCE_CUSTOM_DRAW)

obs.obs_register_source(as_custom_source)
