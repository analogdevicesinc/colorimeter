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

    def select_gain(self, gain):
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
    def to_sint(self, buf):
        i = (int(buf[2]) << 16) | (int(buf[1]) << 8) | int(buf[0])
        if i > 2**22:
            i = i - 2**23 + 1
        return i

    def __read_sample(self, avg = 1):
        n = 5000
        buf = iio.Buffer(self.device, n)
        buf.refill()
        data = self.device.read(buf)
        a1 = 0.0
        a2 = 0.0
        a=  []
        for offset in range(0, n * 16, 16):
            s = data[offset:offset+16]
            ch1 = self.to_sint(s[0:4])
            ch2 = self.to_int(s[4:8])
            ch3 = self.to_sint(s[8:12])
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
        fast_capture(self.device._device, 5000, byref(a1), byref(a2))
        return (a1.value, a2.value)
