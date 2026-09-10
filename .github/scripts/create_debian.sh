#!/bin/bash
set -e

version=$1
source_code=$(basename "$PWD")

echo "Building version: $version"
echo "Architecture: $architecture"
echo "Source directory: $source_code"

if [[ "$STAGE" == "dev" ]]; then
    rm -rf packaging/debian
    mv packaging/debian_dev packaging/debian
fi

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
