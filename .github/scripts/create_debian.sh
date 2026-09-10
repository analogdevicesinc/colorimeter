#!/bin/bash
set -e

version=$1
source_code=$(basename "$PWD")
artifact_name=${ARTIFACT_NAME}

echo "Building version: $version"
echo "Architecture: $architecture"
echo "Source directory: $source_code"

# Use sudo only if not running as root
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update
$SUDO apt-get install -y \
    build-essential cmake make devscripts debhelper rpm \
    pybuild-plugin-pyproject python3-setuptools dh-python \
    libc6 libxml2-dev libcdk5-dev libaio-dev libusb-1.0-0-dev \
    libserialport-dev libavahi-client-dev bison flex wget \
    graphviz libavahi-common-dev bzip2 python3-pip

# Install libbio
wget https://raw.githubusercontent.com/analogdevicesinc/wiki-scripts/refs/heads/main/utils/cloudsmith_utils/cloudsmith_helper.py -O /tmp/cloudsmith_helper.py
mkdir -p build && cd build
$PYTHON /tmp/cloudsmith_helper.py \
    --method get_artifacts_from_location \
    --repo external \
    --package_version "libiio-v0~latest" \
    --package_name "$artifact_name"
$SUDO dpkg -i "libiio-0.26.g-$artifact_name"

export CMAKE_OPTIONS="-DPYTHON_BINDINGS=ON -DENABLE_PACKAGING=ON -DDEB_DETECT_DEPENDENCIES=ON .."
$SUDO -H $PYTHON -m pip install pylibiio --no-binary :all:

# Update version in debian files
sed -i "s/@VERSION@/$version-1/" packaging/debian/changelog
sed -i "s/@DATE@/$(date -R)/" packaging/debian/changelog

# Copy debian directory to source root
cp -r packaging/debian .

# Remove packaging directory to avoid including it in the source tarball
rm -rf packaging

# Create the orig tarball
pushd ..
tar czf ${source_code}_${version}.orig.tar.gz \
    --exclude='.git' \
    --exclude='debian' \
    $source_code
popd

# Build the debian package
debuild
