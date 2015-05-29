#!/usr/bin/env python
#
# Copyright (C) 2015 Analog Devices, Inc.
# Author: Paul Cercueil <paul.cercueil@analog.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

from distutils.core import setup

setup(name='adi_colorimeter',
		version='1.0',
		description='ADI CN0363 Colorimeter',
		url='http://wiki.analog.com/resources/tools-software/linux-software/colorimeter',
		package_dir={'adi_colorimeter': 'lib'},
		packages=['adi_colorimeter'],
		)
