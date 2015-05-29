/*
* Copyright (C) 2014-2015 Analog Devices, Inc.
*
* All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*     - Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     - Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in
*       the documentation and/or other materials provided with the
*       distribution.
*     - Neither the name of Analog Devices, Inc. nor the names of its
*       contributors may be used to endorse or promote products derived
*       from this software without specific prior written permission.
*     - The use of this software may or may not infringe the patent rights
*       of one or more patent holders.  This license does not release you
*       from the requirement that you obtain separate licenses from these
*       patent holders to use this software.
*     - Use of the software either in source or binary form, must be run
*       on or directly connected to an Analog Devices Inc. component.
*    
* THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
* INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
* PARTICULAR PURPOSE ARE DISCLAIMED.
*
* IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
* RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
* BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
* STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
* THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <math.h>
#include <iio.h>
#include <stdint.h>
#include <errno.h>

int capture_data(struct iio_device *dev, unsigned int skip, unsigned int n,
	double *a1, double *a2)
{
	struct iio_buffer *buf;
	unsigned int i;
	int32_t *data;
	double i1, q1, i2, q2;
	double _a1, _a2;

	buf = iio_device_create_buffer(dev, n + skip, false);
	if (!buf)
		return -errno;

	iio_buffer_refill(buf);

	data = iio_buffer_start(buf);

	_a1 = 0.0;
	_a2 = 0.0;

	for (i = skip; i < n + skip; i++) {
		i1 = data[i*4+0];
		q1 = data[i*4+1];
		i2 = data[i*4+2];
		q2 = data[i*4+3];
		_a1 += sqrt(i1*i1 + q1*q1);
		_a2 += sqrt(i2*i2 + q2*q2);
	}

	*a1 = _a1 / n;
	*a2 = _a2 / n;

	iio_buffer_destroy(buf);

	return 0;
}
