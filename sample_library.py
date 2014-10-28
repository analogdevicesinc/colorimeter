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

import os

class Sample(object):
    
    def __init__(self, name, red, green, blue):
        self.name = name
        self.absorbance = (red, green, blue)

    @classmethod
    def load(cls, filename):
        f = open(filename)
        l = f.read().strip()
        f.close()

        try:
            r, g, b = [float(x) for x in l.split(' ')]
        except:
            return None

        name = os.path.basename(filename).split('.')[0]

        return Sample(name, r, g, b)

    def save(self, location):
        f = open(os.path.join(location, self.name + '.csv'), 'w')
        f.write('%f %f %f\n' % self.absorbance)
        f.close()

    def delete(self, location):
        os.remove(os.path.join(location, self.name + '.csv'))

    def compare(self, other):
        s = 0
        for i in range(0, 3):
            d = self.absorbance[i] - other.absorbance[i]
            s += d * d

        return s


class SampleLibrary(object):

    def __init__(self, location):
        self.location = location
        self.samples = []
        if not os.path.exists(os.path.dirname(location)):
            os.makedirs(os.path.dirname(location), 0755)
        else:
            for f in os.listdir(location):
                f = os.path.join(location, f)
                if not os.path.isfile(f):
                    continue
                try:
                    self.samples.append(Sample.load(f))
                except Exception, e:
                    print(e)

    def __iter__(self):
        return self.samples.__iter__()

    def add(self, sample):
        self.samples.append(sample)
        sample.save(self.location)

    def remove(self, sample):
        self.samples.remove(sample)
        sample.delete(self.location)
        
    def match(self, sample):
        best_score = 0
        best_match = None
        for m in self.samples:
            score = sample.compare(m)
            if best_match is None or score < best_score:
                best_score = score
                best_match = m

        return m
