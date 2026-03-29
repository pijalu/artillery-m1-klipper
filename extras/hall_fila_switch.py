# Overrules Artillery M1 Pro proprietary BS
#
# Copyright (C) 2026  Pierre Poissinger <pierre.poissinger@gmail.com>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
from . import hall_filament_width_sensor

def load_config(config):
    return hall_filament_width_sensor.HallFilamentWidthSensor(config)