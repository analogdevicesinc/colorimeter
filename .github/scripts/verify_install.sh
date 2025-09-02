#!/bin/bash

install_location="${1:-/usr}"

if [ ! -d "$install_location/share/adi_colorimeter/" ] || [ ! -d "$install_location/lib/adi_colorimeter/" ] || \
    [ ! -d "$install_location/share/polkit-1/actions/" ] || [ ! -d "$install_location/share/applications" ] || \
    [ ! -d "$install_location/share/icons/hicolor/16x16/apps/" ] || [ ! -d "$install_location/share/icons/hicolor/32x32/apps/" ] || 
    [ ! -d "$install_location/share/icons/hicolor/64x64/apps/" ]; then 
        echo "Installation directories not found!"
        exit 1
fi

if [ ! -f "$install_location/bin/adi_colorimeter" ] || [ ! -f "$install_location/lib/adi_colorimeter/capture.so" ] || \
    [ ! -f "$install_location/share/adi_colorimeter/adi_colorimeter.glade" ] || \
    [ ! -f "$install_location/share/polkit-1/actions/org.adi.pkexec.adi_colorimeter.policy" ] || \
    [ ! -f "$install_location/share/applications/adi-colorimeter.desktop" ] || \
    [ ! -f "$install_location/share/icons/hicolor/16x16/apps/adi-colorimeter.png" ] || \
    [ ! -f "$install_location/share/icons/hicolor/32x32/apps/adi-colorimeter.png" ] || \
    [ ! -f "$install_location/share/icons/hicolor/64x64/apps/adi-colorimeter.png" ]; then
        echo "Installation files not found!"
        exit 1
fi

check_pip=$(pip show adi_colorimeter | grep -i warning)
if [ "$check_pip" ]; then
    echo "Pip package adi_colorimeter install failed!"
    exit 1
fi

echo "Colorimeter installed successfully."
