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
obs_libre_macros_version = "1.0.0"
obs = obslua -- needs to be global for use in repl
ffi = require "ffi"
jit = require "jit"
bit = require "bit"

function script_description()
  return copyleft:sub(1,163) .. 'Version: ' .. obs_libre_macros_version ..
  '\nReleased under GNU Affero General Public License, AGPLv3+'
end
-- function script_tick(dt) end -- external loop, can be used for messaging/signalling

if ffi.os == "OSX" then
  ok,obsffi = pcall(ffi.load, "obs.0.dylib")
else
  ok,obsffi = pcall(ffi.load, "obs")
end
if not ok then print('Failed to load native library') end

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
  local action = Timer:init{duration=s}
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

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
-- id - obs keyboard id , c - character , cs - character with shift pressed
qwerty_minimal_keyboard_layout = {
  {id="OBS_KEY_BACKSPACE",c="backspace",cs="backspace"},
  {id="OBS_KEY_RETURN",c="enter",cs="enter"},
  {id="OBS_KEY_TAB",c="tab",cs="tab"},
  {id="OBS_KEY_ASCIITILDE",c="`",cs="~"},
  {id ="OBS_KEY_COMMA",c=",",cs="<"},
  {id ="OBS_KEY_PLUS",c="=",cs="+"},
  {id ="OBS_KEY_MINUS",c="-",cs="_"},
  {id ="OBS_KEY_BRACKETLEFT",c="[",cs="{"},
  {id ="OBS_KEY_BRACKETRIGHT",c="]",cs="}"},
  {id ="OBS_KEY_PERIOD",c=".",cs=">"},
  {id ="OBS_KEY_APOSTROPHE",c="'",cs='"'},
  {id ="OBS_KEY_SEMICOLON",c=";",cs=":"},
  {id ="OBS_KEY_SLASH",c="/",cs="?"},
  {id ="OBS_KEY_SPACE",c=" ",cs=" "},
  {id ="OBS_KEY_0",c="0",cs=")"},
  {id ="OBS_KEY_1",c="1",cs="!"},
  {id ="OBS_KEY_2",c="2",cs="@"},
  {id ="OBS_KEY_3",c="3",cs="#"},
  {id ="OBS_KEY_4",c="4",cs="$"},
  {id ="OBS_KEY_5",c="5",cs="%"},
  {id ="OBS_KEY_6",c="6",cs="^"},
  {id ="OBS_KEY_7",c="7",cs="&"},
  {id ="OBS_KEY_8",c="8",cs="*"},
  {id ="OBS_KEY_9",c="9",cs="("},
  {id ="OBS_KEY_A",c="a",cs="A"},
  {id ="OBS_KEY_B",c="b",cs="B"},
  {id ="OBS_KEY_C",c="c",cs="C"},
  {id ="OBS_KEY_D",c="d",cs="D"},
  {id ="OBS_KEY_E",c="e",cs="E"},
  {id ="OBS_KEY_F",c="f",cs="F"},
  {id ="OBS_KEY_G",c="g",cs="G"},
  {id ="OBS_KEY_H",c="h",cs="H"},
  {id ="OBS_KEY_I",c="i",cs="I"},
  {id ="OBS_KEY_J",c="j",cs="J"},
  {id ="OBS_KEY_K",c="k",cs="K"},
  {id ="OBS_KEY_L",c="l",cs="L"},
  {id ="OBS_KEY_M",c="m",cs="M"},
  {id ="OBS_KEY_N",c="n",cs="N"},
  {id ="OBS_KEY_O",c="o",cs="O"},
  {id ="OBS_KEY_P",c="p",cs="P"},
  {id ="OBS_KEY_Q",c="q",cs="Q"},
  {id ="OBS_KEY_R",c="r",cs="R"},
  {id ="OBS_KEY_S",c="s",cs="S"},
  {id ="OBS_KEY_T",c="t",cs="T"},
  {id ="OBS_KEY_U",c="u",cs="U"},
  {id ="OBS_KEY_V",c="v",cs="V"},
  {id ="OBS_KEY_W",c="w",cs="W"},
  {id ="OBS_KEY_X",c="x",cs="X"},
  {id ="OBS_KEY_Y",c="y",cs="Y"},
  {id ="OBS_KEY_Z",c="z",cs="Z"},
}

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
function print_source_name(source)
  print(obs.obs_source_get_name(source))
end

function sname(source)
  return obs.obs_source_get_name(source)
end

return_source_name = sname

function get_scene_sceneitem(scene_name,scene_item_name)
  local sceneitem;
  local scenes = obs.obs_frontend_get_scenes()
  for _,scene in pairs(scenes) do
    if sname(scene) == scene_name then
      scene = obs.obs_scene_from_source(scene)
      sceneitem = obs.obs_scene_find_source_recursive(scene,scene_item_name)
    end
  end
  obs.source_list_release(scenes)
  return sceneitem
end

LMB,RMB,MOUSE_HOOKED = false,false,false
function htk_1_cb(pressed) LMB = pressed end
function htk_2_cb(pressed) RMB = pressed end
function hook_mouse_buttons()
  if MOUSE_HOOKED then return error('already hooked mouse') end
  local key_1 = '{"htk_1_mouse": [ { "key": "OBS_KEY_MOUSE1" } ],'
  local key_2 = '"htk_2_mouse": [ { "key": "OBS_KEY_MOUSE2" } ]}'
  local json_s = key_1 .. key_2
  local default_hotkeys = {
    {id='htk_1_mouse',des='LMB state',callback=htk_1_cb},
    {id='htk_2_mouse',des='RMB state',callback=htk_2_cb},
  }
  local s = obs.obs_data_create_from_json(json_s)
  for _,v in pairs(default_hotkeys) do
    local a = obs.obs_data_get_array(s,v.id)
    h = obs.obs_hotkey_register_frontend(v.id,v.des,v.callback)
    obs.obs_hotkey_load(h,a)
    obs.obs_data_array_release(a)
  end
  obs.obs_data_release(s)
  MOUSE_HOOKED = true
end

function get_modifiers(ctx)
  local key_modifiers = ctx or {}
  local shift = key_modifiers.shift or false
  local control = key_modifiers.control or false
  local alt = key_modifiers.alt or false
  local command = key_modifiers.command or false
  local modifiers = 0

  if shift then modifiers = bit.bor(modifiers,obs.INTERACT_SHIFT_KEY ) end
  if control then modifiers = bit.bor(modifiers,obs.INTERACT_CONTROL_KEY ) end
  if alt then modifiers = bit.bor(modifiers,obs.INTERACT_ALT_KEY ) end
  if command then modifiers = bit.bor(modifiers,obs.INTERACT_COMMAND_KEY ) end
  return modifiers
end

function send_hotkey(hotkey_id_name,key_modifiers)
  local combo = obs.obs_key_combination()
  combo.modifiers = get_modifiers(key_modifiers)
  combo.key = obs.obs_key_from_name(hotkey_id_name)

  if not modifiers and -- there is should be OBS_KEY_NONE, but it is missing in obslua
    (combo.key == 0 or combo.key >= obs.OBS_KEY_LAST_VALUE) then
    return error('invalid key-modifier combination')
  end

  obs.obs_hotkey_inject_event(combo,false)
  obs.obs_hotkey_inject_event(combo,true)
  obs.obs_hotkey_inject_event(combo,false)
end

function char_to_obskey(char)
  for _,row in pairs(qwerty_minimal_keyboard_layout) do
    if char == row.c or char == row.cs then
      return row.id
    end
  end
  error('character not found within qwerty minimal table')
end
c2o = char_to_obskey

function send_hotkey_tbs1(source,hotkey_id_name,key_up,key_modifiers)
  local key = obs.obs_key_from_name(hotkey_id_name)
  local vk = obs.obs_key_to_virtual_key(key)
  local event = obs.obs_key_event()
  event.native_vkey = vk
  event.modifiers = get_modifiers(key_modifiers)
  event.native_modifiers = event.modifiers
  event.native_scancode = vk
  event.text = ""
  obs.obs_source_send_key_click(source,event,key_up)
end

function send_hotkey_tbs2(source,char,key_up,key_modifiers)
  local event = obs.obs_key_event()
  event.native_vkey = 0
  event.native_modifiers = 0
  event.native_scancode = 0
  event.modifiers = get_modifiers(key_modifiers)
  event.text = char
  obs.obs_source_send_key_click(source,event,key_up)
end

function send_mouse_click_tbs(source,opts,key_modifiers)
  local event = obs.obs_mouse_event()
  event.modifiers = get_modifiers(key_modifiers)
  event.x = opts.x
  event.y = opts.y
  obs.obs_source_send_mouse_click(
    source,event,opts.button_type,opts.mouse_up,opts.click_count
    )
end

function send_mouse_move_tbs(source,x,y,key_modifiers)
  local event = obs.obs_mouse_event()
  event.modifiers = get_modifiers(key_modifiers)
  event.x = x
  event.y = y
  obs.obs_source_send_mouse_move(source,event,false) -- do not leave
end

function send_mouse_wheel_tbs(source,x,y,x_delta,y_delta,key_modifiers)
  local event = obs.obs_mouse_event()
  event.x = opts.x or 0
  event.y = opts.y or 0
  event.modifiers = get_modifiers(key_modifiers)
  local x_delta = opts.x_delta or 0
  local y_delta = opts.y_delta or 0
  obs.obs_source_send_mouse_wheel(source,event,x_delta,y_delta)
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
  function callback_htk(data,id,key)
    local name = obsffi.obs_hotkey_get_name(key)
    if ffi.string(name) == description then
      htk_id = tonumber(id)
      return false
    else
      return true
    end
  end
  local cb = ffi.cast("obs_hotkey_enum_func",callback_htk)
  obsffi.obs_enum_hotkeys(cb,nil)
  if htk_id then
    obs.obs_hotkey_trigger_routed_callback(htk_id,false)
    obs.obs_hotkey_trigger_routed_callback(htk_id,true)
    obs.obs_hotkey_trigger_routed_callback(htk_id,false)
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

LVL,NOISE,LOCK = "?",0,false
function callback_meter(data,mag,peak,input)
  LVL = 'Volume lvl is :' .. tostring(tonumber(peak[0]))
  NOISE = tonumber(peak[0])
end


jit.off(callback_meter)

function volume_level(source_name)
  if LOCK then return error("cannot attach to more than 1 source") end
  local source = obsffi.obs_get_source_by_name(source_name)
  local volmeter = obsffi.obs_volmeter_create(obsffi.OBS_FADER_LOG)
  -- https://github.com/WarmUpTill/SceneSwitcher/blob/214821b69f5ade803a4919dc9386f6351583faca/src/switch-audio.cpp#L194-L207
  local cb = ffi.cast("obs_volmeter_updated_t",callback_meter)
  obsffi.obs_volmeter_add_callback(volmeter,cb,nil)
  obsffi.obs_volmeter_attach_source(volmeter,source)
  obsffi.obs_source_release(source)
  LOCK = true
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

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
as_custom_source = as_video_filter

function as_custom_source:get_name() return "AGPLv3+ obs-libre-macros by upgradeQ" end
function as_custom_source:video_render(settings) end
function as_custom_source:get_height() return 200 end
function as_custom_source:get_width() return 200 end
function as_custom_source:load(settings) as_custom_source.reg_htk(self,settings) end

function as_custom_source:update(settings)
  self.code = obs.obs_data_get_string(settings,"_text")
  self.autorun = obs.obs_data_get_bool(settings,"_autorun")
  self.mv1 = obs.obs_data_get_double(settings,"_mv1")
  self.mv2 = obs.obs_data_get_double(settings,"_mv2")
  self.hotreload = obs.obs_data_get_string(settings,"_hotreload")
  self.p1 = obs.obs_data_get_string(settings,"_p1")
  self.p2 = obs.obs_data_get_string(settings,"_p2")
-- custom source logic for registering hotkeys
  if not self.created_hotkeys then
    as_custom_source.reg_htk(self,settings)
  end
end

function as_custom_source:reg_htk(settings)
  -- note it's not a filter but rather a source itself
  local source_name = obs.obs_source_get_name(self.filter)
  if source_name then
    self.hotkeys["2;" .. source_name] = function()
      self.hotkey_dispatch = true
    end
    self.hotkeys["3;" .. source_name] = function(pressed)
      self.pressed = pressed
    end

    for k,v in pairs(self.hotkeys) do
      self.hk[k] = obs.OBS_INVALID_HOTKEY_ID
    end

    for k, v in pairs(self.hotkeys) do
      if k:sub(1,1) == "3" then -- starts with 3 symbol
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
as_custom_source.id = "s_console_source"
as_custom_source.type = obs.OBS_SOURCE_TYPE_SOURCE
as_custom_source.output_flags = bit.bor(obs.OBS_SOURCE_VIDEO,obs.OBS_SOURCE_CUSTOM_DRAW,obs.OBS_SOURCE_AUDIO)

obs.obs_register_source(as_custom_source)
