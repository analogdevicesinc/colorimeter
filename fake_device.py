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
import random
import math

class lpf(object):

    coeff = [
 0.9969521814448669,  1.0095191049382,  1.036040572178033,  1.076691097465995,  1.131604278927488,  1.200872043728491,  1.284544021067372,  1.382627045752516,  1.495084794750207,  1.621837558650676,  1.762762149555303,  1.917691946435881,  2.086417078559471,  2.268684747111029,  2.464199684682447,  2.672624751832398,  2.893581669458193,  3.126651885260147,  3.371377572122589,  3.627262755785014,  3.893774568733693,  4.17034462680984,  4.456370524606815,  4.751217445317107,  5.054219880291768,  5.364683453191732,  5.681886843243528,  6.005083801762642,  6.333505255777332,  6.666361492275443,  7.002844416307593,  7.342129875913376,  7.683380046593454,  8.025745867831239,  8.368369523973101,  8.710386961607547,  9.050930435441098,  9.389131074553305,  9.724121460824895,  10.05503821127267,  10.38102455599212,  10.70123290340433,  11.01482738452746,  11.32098636804492,  11.61890493802247,  11.90779732623372,  12.18689929118925,  12.45547043612603,  12.71279645840308,  12.95819132296338,  13.19099935276188,  13.41059722932359,  13.61639589688306,  13.80784236386668,  13.98442139581076,  14.14565709415992,  14.2911143557616,  14.42040020826094,  14.53316501700579,  14.62910355949212,  14.70795596381395,  14.76950850802866,  14.8135942778052,  14.84009368018911,  14.84893481179152,  14.84009368018911,  14.8135942778052,  14.76950850802866,  14.70795596381395,  14.62910355949212,  14.53316501700579,  14.42040020826093,  14.2911143557616,  14.14565709415992,  13.98442139581076,  13.80784236386668,  13.61639589688306,  13.41059722932359,  13.19099935276188,  12.95819132296338,  12.71279645840309,  12.45547043612603,  12.18689929118925,  11.90779732623372,  11.61890493802247,  11.32098636804493,  11.01482738452746,  10.70123290340434,  10.38102455599212,  10.05503821127267,  9.724121460824895,  9.389131074553305,  9.050930435441103,  8.710386961607547,  8.368369523973101,  8.025745867831237,  7.683380046593456,  7.342129875913378,  7.002844416307597,  6.66636149227544,  6.333505255777332,  6.005083801762643,  5.681886843243532,  5.364683453191734,  5.054219880291766,  4.751217445317107,  4.456370524606815,  4.17034462680984,  3.893774568733697,  3.627262755785017,  3.371377572122588,  3.126651885260147,  2.893581669458194,  2.6726247518324,  2.464199684682449,  2.268684747111028,  2.086417078559471,  1.917691946435882,  1.762762149555304,  1.621837558650677,  1.495084794750209,  1.382627045752516,  1.284544021067372,  1.200872043728491,  1.131604278927488,  1.076691097465996,  1.036040572178033,  1.0095191049382,  0.9969521814448669, 	]

    def __init__(self):
        self.values = [0] * len(self.coeff)

    def add_input(self, val):
        self.values = self.values[1:]
        self.values.append(val)

    def get_output(self):
        o = 0.0
        for c, v in zip(self.coeff, self.values):
            o += c * v / 1000
        return o

class Channel(object):

    def __init__(self):
        self.lpf_i = lpf()
        self.lpf_q = lpf()
        self.n = 0.0
        self.change()

    def change(self):
        self.phase = random.random() * math.pi - math.pi / 2
        self.amplitude = random.random() * 100
        print("Phase: %f, Amplitude: %f" % (self.phase + math.pi / 2, self.amplitude))

    def noise(self):
        return (random.random() - random.random()) * 0.1

    def get_sample(self):
        w1 = math.cos(self.n / 10.0)
        w2 = math.sin(self.n / 10.0)

        sig = math.sin(self.n / 10.0  + self.phase) * self.amplitude + self.noise()
        self.lpf_i.add_input(w1 * sig)
        i = self.lpf_i.get_output() * 2
        self.lpf_q.add_input(-w2 * sig)
        q = self.lpf_q.get_output() * 2
        a = math.sqrt(i**2 + q**2)
        if i != 0.0:
            p = math.atan(q/i) + math.pi / 2
        else:
            if q < 0:
                p = -math.pi
            else:
                p = math.pi

        self.n += 10.0

        return (a, p)

class FakeDevice(object):
    
    def __init__(self):
        self.x = 0.5
        self.y = 0.5
        self.led = 0
        self.m = 0
        self.ref_ch = Channel()
        self.sample_ch = Channel()
        self.gain = {}
        self.gain[1] = random.random()
        self.gain[2] = random.random()
        self.gain[3] = random.random()

    def select_led(self, led):
        print("Select LED: %d" % led)
        self.led = led
        self.x = 0.5
        self.y = 0.5

    def select_gain(self, channel, gain):
        print("Select Gain %d %d" % (channel, gain))

    def set_excitation_frequency(self, freq):
        print("Set Excitation Freq %d" % freq)

    def set_lpf_cutoff_frequency(self, freq):
        print("Set LPF Cutoff Freq %d" % freq)

    def noise(self):
        return (random.random() - random.random()) * 0.1

    def read_sample(self, avg = 1):
        if self.led == 0:
            return [(0.01 + self.noise()) * 50000, (0.01 + self.noise()) * 50000]

        x = 0.0
        y = 0.0
        for i in range(0, avg):
            a = self.ref_ch.get_sample()
            b = self.sample_ch.get_sample()
            x += a[0]
            y += b[0]
#            if a[0] < b[0]:
 #               y += a[0] - b[0] + math.pi
 #           else:
  #              y += a[0] - b[0]

        x /= avg
        y /= avg

        x *= 33000# * self.gain[self.led]
        y *= 33000# * self.gain[self.led]

        self.m += 1
        if self.m == 30:
#            self.ref_ch.change()
#            self.sample_ch.change()
            self.m = 0
            self.gain[1] = random.random()
            self.gain[2] = random.random()
            self.gain[3] = random.random()
 
        return (x, y)

