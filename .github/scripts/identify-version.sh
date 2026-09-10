#!/bin/bash

set -e

# Extract version from setup.py
setup_version=$(grep -oP "version\s*=\s*['\"]\\K[0-9]+\\.[0-9]+(\\.[0-9]+)?" setup.py)

if [[ -z "$setup_version" ]]; then
	echo "Failed to extract version from setup.py, using default"
	setup_version="0.0.1+${GITHUB_SHA}"
fi

echo "Version to use: $setup_version"
echo "version=$setup_version" >> "$GITHUB_OUTPUT"

