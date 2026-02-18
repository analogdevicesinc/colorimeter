#!/bin/bash
set -e

version=$1
architecture=$(dpkg --print-architecture)
source_code=$(basename "$PWD")

echo "Building version: $version"
echo "Architecture: $architecture"
echo "Source directory: $source_code"

# Install dependencies based on user (root or non-root)
if [ "$(id -u)" -eq 0 ]; then
    apt-get update
    apt-get install -y build-essential make devscripts debhelper pybuild-plugin-pyproject python3 python3-setuptools dh-python libiio-dev
else
    sudo apt-get update
    sudo apt-get install -y build-essential make devscripts debhelper pybuild-plugin-pyproject python3 python3-setuptools dh-python libiio-dev
fi

# Update version and architecture in debian files
sed -i "s/@VERSION@/$version-1/" packaging/debian/changelog
sed -i "s/@DATE@/$(date -R)/" packaging/debian/changelog
sed -i "s/@ARCHITECTURE@/$architecture/" packaging/debian/control

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
