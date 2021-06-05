copyleft ="""
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
"""
import obspython as obs
from time import sleep, gmtime, strftime
from contextlib import contextmanager
from threading import Thread
from functools import partial

@contextmanager
def p_data_ar(data_type, field):
    settings = obs.obs_get_private_data()
    get = getattr(obs, f"obs_data_get_{data_type}")
    try:
        yield get(settings, field)
    finally:
        obs.obs_data_release(settings)

def send_to_private_data(data_type, field, result):
    settings = obs.obs_data_create()
    set = getattr(obs, f"obs_data_set_{data_type}")
    set(settings, field, result)
    obs.obs_apply_private_data(settings)
    obs.obs_data_release(settings)

def execute_from_private_registry(address=None):
    handshake = "__py_dispatch" if not address else "__py_dispatch%s" % address
    address = "__py_registry" if not address else "__py_registry%s" % address
    with p_data_ar("string", address) as code:
        with p_data_ar("bool", handshake) as proceed:
            if proceed:
                exec(code)
                send_to_private_data("bool", handshake, False)

def execute_lua(address=None, code = None):
    handshake = "__lua_dispatch" if not address else "__lua_dispatch%s" % address
    address = "__lua_registry" if not address else "__lua_registry%s" % address
    code = code or """
    print("hello from %s, time: %s")
    """ % ("python", strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime()))
    send_to_private_data("string", address, code)
    send_to_private_data("bool", handshake, True)


def event_loop():
    while True:
        sleep(1/60)
        execute_from_private_registry()
        execute_lua()

start_timer = True # obs will not close properly with threads
if start_timer:
    obs.timer_add(execute_from_private_registry,16)
    obs.timer_add(execute_lua,1000)
    another_func_lua = partial(execute_lua,"1", "print(2); print_source_name(t.source)")
    another_func_py = partial(execute_from_private_registry,"2") # accept from 2
    obs.timer_add(another_func_lua, 16)
    obs.timer_add(another_func_py, 16)

else:
    t = Thread(target=event_loop)
    t.start()

# vim: ft=python ts=4 sw=4 et sts=4
