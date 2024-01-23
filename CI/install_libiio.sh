#!/bin/bash

libiio_branch="libiio-v0"

sudo apt-get -y update
sudo apt-get -y install git build-essential libxml2-dev bison flex libcdk5-dev cmake libaio-dev libusb-1.0-0-dev libserialport-dev libavahi-client-dev doxygen graphviz python3 python3-pip python3-setuptools

git clone -b "$libiio_branch" https://github.com/analogdevicesinc/libiio.git
cd libiio

mkdir build && cd build
sudo cmake ../ -DCPP_BINDINGS=ON -DPYTHON_BINDINGS=ON
sudo make -j$(nproc)

sudo make install
