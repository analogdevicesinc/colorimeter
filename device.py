#
# Copyright (C) 2014 Analog Devices, Inc.
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

from ctypes import POINTER, Structure, cdll, c_uint, c_int, \
        c_void_p, c_double, byref

capture_lib = cdll.LoadLibrary('./capture.so')
fast_capture = capture_lib.capture_data
fast_capture.restype = c_int
fast_capture.archtypes = (c_void_p, c_uint, c_double, c_double)

class Device(object):

    def __init__(self):
        self.ctx = iio.LocalContext()

        self.device = None
        for d in self.ctx.devices:
            if d.name == "axi_ad7175":
                self.device = d
                break
        
        if not self.device:
            raise Exception("No Device found!")

        for ch in self.device.channels:
            ch.enabled = True

        self.ad7175_reg_write(0x10, 0x800100) # CH1
        self.ad7175_reg_write(0x11, 0x804300) # CH2
        self.ad7175_reg_write(0x28, 0x30000) # FILTERCON0
        self.ad7175_reg_write(0x20, 0x132000)
        self.ad7175_reg_write(0x21, 0x132000)

    def ad7175_reg_write(self, reg, val):
        self.device.reg_write(0x48, reg)
        self.device.reg_write(0x4c, val)
        self.device.reg_write(0x50, 0x2)

    def ad7175_read_reg(self, reg):
        self.device.reg_write(0x48, reg)
        self.device.reg_write(0x50, 0x1)
        return self.device.read_reg(0x4c)

    def select_led(self, led):
        if led == 0:
            led = 3
        else:
            led = led - 1
        self.ad7175_reg_write(0x06, (0xc | led) << 8)

    def select_gain(self, channel, gain):
        pass

    def set_excitation_frequency(self, freq):
        if freq < 1:
            freq = 1
        phase_inc =  int(round((freq * 2**32) / 100000000.0))
        self.ad7175_reg_write(0x41, phase_inc)

    def set_lpf_cutoff_frequency(self, freq):
        pass

    def to_int(self, buf):
        i = (int(buf[3]) << 24) | (int(buf[2]) << 16) | (int(buf[1]) << 8) | int(buf[0])
        return i

    def __read_sample(self, avg = 1):
        n = 2500
        buf = iio.Buffer(self.device, n)
        buf.refill()
        data = self.device.read(buf)
        a1 = 0.0
        a2 = 0.0
        a=  []
        for offset in range(0, n * 16, 16):
            s = data[offset:offset+16]
            ch1 = self.to_int(s[0:4]) - 2**23
            ch2 = self.to_int(s[4:8])
            ch3 = self.to_int(s[8:12]) - 2**23
            ch4 = self.to_int(s[12:16])
            phase1 = ch2 / float(2**31) * math.pi
            phase2 = ch4 / float(2**31) * math.pi
            a.append((ch1, (-math.sin(phase1) + 1.0) * 33000))
            i1 = math.cos(phase1) * ch1
            q1 = math.sin(phase1) * ch1
            a1 += math.sqrt(i1**2 + q1**2)
            i2 = math.cos(phase2) * ch3
            q2 = math.sin(phase2) * ch3
            a2 += math.sqrt(i2**2 + q2**2)
#            a.append((a1, a2))

        return a

    def read_sample(self, avg = 1):
        a1 = c_double()
        a2 = c_double()
        fast_capture(self.device._device, 2500, byref(a1), byref(a2))
        return (a1.value, a2.value)
