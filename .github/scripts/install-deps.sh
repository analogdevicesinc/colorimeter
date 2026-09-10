#!/bin/bash

set -e

# Install packages based on architecture
if [[ "$ARCHITECTURE" == "arm64" || "$ARCHITECTURE" == "armhf" ]]; then
    SUDO=""
else
    SUDO="sudo"
fi
${SUDO} apt-get update

DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get install -y \
          build-essential cmake make devscripts debhelper rpm \
          pybuild-plugin-pyproject python3 python3-setuptools dh-python \
          libc6 libxml2-dev libcdk5-dev libaio-dev libusb-1.0-0-dev \
          libserialport-dev libavahi-client-dev bison flex wget \
          graphviz libavahi-common-dev bzip2 python3-pip

${SUDO} rm -f /usr/lib/python*/EXTERNALLY-MANAGED
python3 -m pip install requests

# Install libiio
if [[ "$STAGE" == "dev" ]]; then
    wget https://raw.githubusercontent.com/analogdevicesinc/wiki-scripts/refs/heads/main/utils/cloudsmith_utils/cloudsmith_helper.py \
	    -O /tmp/cloudsmith_helper.py

    python3 /tmp/cloudsmith_helper.py \
	    --method get_artifacts_from_location \
	    --repo external \
	    --package_version "libiio-v0~latest" \
	    --package_name "$ARTIFACT_NAME"
          
    ${SUDO} dpkg -i *.deb
    ${SUDO} ldconfig
else
    ${SUDO} apt-get install -y libiio-dev libiio0
    ${SUDO} ldconfig
fi

# The libiio comes by default with the package, but for checking
if [[ "$STAGE" == "rel" && ( "$ARCHITECTURE" == "arm64" || "$ARCHITECTURE" == "armhf" ) ]]; then
    ${SUDO} apt-get install -y python3-libiio
else
    python3 -m pip install pylibiio --no-binary :all:
fi
