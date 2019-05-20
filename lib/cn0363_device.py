# -*- coding: iso-8859-15 -*-
#
# Copyright (C) 2014-2015 Analog Devices, Inc.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#     - Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     - Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#     - Neither the name of Analog Devices, Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#     - The use of this software may or may not infringe the patent rights
#       of one or more patent holders.  This license does not release you
#       from the requirement that you obtain separate licenses from these
#       patent holders to use this software.
#     - Use of the software either in source or binary form, must be run
#       on or directly connected to an Analog Devices Inc. component.
#
# THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED.
#
# IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
# RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import iio
import struct
import time
import math
import os

from adi_colorimeter.config import PREFIX

from ctypes import POINTER, Structure, cdll, c_uint, c_int, \
        c_void_p, c_double, byref

capture_lib = cdll.LoadLibrary(os.path.join(PREFIX, 'lib/adi_colorimeter/capture.so'))
fast_capture = capture_lib.capture_data
fast_capture.restype = c_int
fast_capture.archtypes = (c_void_p, c_uint, c_uint, c_double, c_double)

GPIO_DIR = '/sys/class/gpio/'
SPI_DIR = '/sys/bus/spi/devices/'

class GPIO(object):

    def __init__(self, controller, gpio):
        self.gpio = controller.base + gpio
        self.path = os.path.join(GPIO_DIR, 'gpio{}'.format(self.gpio))

        try:
            f = open(os.path.join(GPIO_DIR, 'export'), 'w')
            f.write('{}'.format(self.gpio))
            f.close()
        except:
            pass

    def __del__(self):
        f = open(os.path.join(GPIO_DIR, 'unexport'), 'w')
        f.write('{}'.format(self.gpio))
        f.close()

    def set_direction_output(self, value):
        f = open(os.path.join(self.path, 'direction'), 'w')
        if value:
            f.write('high')
        else:
            f.write('low')
        f.close()

    def set_direction_input(self):
        f = open(os.path.join(self.path, 'direction'), 'w')
        f.write('in')
        f.close()

    def set_value(self, value):
        f = open(os.path.join(self.path, 'value'), 'w')
        if value:
            f.write('1')
        else:
            f.write('0')
        f.close()

class GPIOController(object):

    @classmethod
    def get_by_name(cls, name):
        for chip in os.listdir(GPIO_DIR):
            if not chip.startswith('gpiochip'):
                continue
            if not os.path.isdir(os.path.join(GPIO_DIR, chip)):
                continue
            f = open(os.path.join(GPIO_DIR, chip, 'label'))
            label = f.read().strip()
            f.close()
            if label == name:
                return GPIOController(os.path.join(GPIO_DIR, chip))

        return None

    def __init__(self, path):
        f = open(os.path.join(path, 'base'))
        self.base = int(f.read().strip())
        f.close()

    def get_gpio(self, offset):
        return GPIO(self, offset)

class Device(object):

    def __init__(self):
        try:
            self.ctx = iio.LocalContext()
        except:
            raise Exception("No IIO context found!")

        self.device = None
        self.zynq_gpio = GPIOController.get_by_name('zynq_gpio')
        self.ad7175_gpio = GPIOController.get_by_name('spi0.0')
        self.rdac = None
        for spi in os.listdir(SPI_DIR):
            if not os.path.isdir(os.path.join(SPI_DIR, spi)):
                continue
            f = open(os.path.join(SPI_DIR, spi, 'modalias'))
            modalias = f.read().strip()
            f.close()
            if modalias == 'spi:ad5201':
                self.rdac = os.path.join(SPI_DIR, spi, 'rdac0')
                break
        for d in self.ctx.devices:
            if d.name == "axi-generic-adc":
                self.device = d
                break

        if not self.device:
            raise Exception("No Device found!")

        if not self.zynq_gpio:
            raise Exception("Failed to find ZYNQ GPIO controller")

        if not self.ad7175_gpio:
            raise Exception("Failed to find AD7175 GPIO controller")

        if not self.rdac:
            raise Exception("Failed to find RDAC controller")

        for ch in self.device.channels:
            ch.enabled = True

        self.gpio_color = []
        self.gpio_color.append(self.ad7175_gpio.get_gpio(0))
        self.gpio_color.append(self.ad7175_gpio.get_gpio(1))

        self.gpio_color[0].set_direction_output(True)
        self.gpio_color[1].set_direction_output(True)

        self.gpio_gain = []
        self.gpio_gain.append(self.zynq_gpio.get_gpio(54 + 32))
        self.gpio_gain.append(self.zynq_gpio.get_gpio(54 + 33))

        self.gpio_gain[0].set_direction_output(False)
        self.gpio_gain[1].set_direction_output(False)


    def select_led(self, led):
        if led == 0:
            led = 3
        else:
            led = led - 1
        self.gpio_color[0].set_value(led & 1)
        self.gpio_color[1].set_value(led & 2)

    def select_gain(self, ch, gain):
        self.gpio_gain[ch].set_value(gain)

    def set_excitation_frequency(self, freq):
#        if freq < 1:
#            freq = 1
#        phase_inc =  int(round((freq * 2**32) / 100000000.0))
#       TODO
        pass

    def get_excitation_frequency(self):
         return 1020

    def set_excitation_current(self, current):
        val = int(round(current * 32 / 25))
        if val > 20:
            val = 20
        elif val < 0:
            val = 0
        f = open(self.rdac, 'w')
        f.write('{}\n'.format(val))
        f.close()

    def get_excitation_current(self):
        f = open(self.rdac)
        val = int(f.read())
        f.close()
        return val * 25 / 32.0

    def set_lpf_cutoff_frequency(self, freq):
        pass

    def to_int(self, buf):
        i = (int(buf[3]) << 24) | (int(buf[2]) << 16) | (int(buf[1]) << 8) | int(buf[0])
        return i
    def to_sint(self, buf):
        i = (int(buf[2]) << 16) | (int(buf[1]) << 8) | int(buf[0])
        if i > 2**22:
            i = i - 2**23 + 1
        return i

    def read_sample(self, avg = 1):
        for ch in self.device.channels:
            if ch.id == "voltage3_i" or ch.id == "voltage3_q" or ch.id == "voltage7_i" or ch.id == "voltage7_q":
                ch.enabled = True
            else:
                ch.enabled = False
        a1 = c_double()
        a2 = c_double()
        fast_capture(self.device._device, 2000, 1200, byref(a1), byref(a2))
        return (a1.value, a2.value)
