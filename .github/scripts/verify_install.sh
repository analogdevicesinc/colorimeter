#!/bin/bash
set -e

INSTALL_PREFIX="${1:-/usr}"

echo "Verifying installation..."

# Check directories
for dir in "$INSTALL_PREFIX/share/adi_colorimeter" \
           "$INSTALL_PREFIX/lib/adi_colorimeter" \
           "$INSTALL_PREFIX/share/polkit-1/actions" \
           "$INSTALL_PREFIX/share/applications" \
           "$INSTALL_PREFIX/share/icons/hicolor/16x16/apps" \
           "$INSTALL_PREFIX/share/icons/hicolor/32x32/apps" \
           "$INSTALL_PREFIX/share/icons/hicolor/64x64/apps"; do
    if [ -d "$dir" ]; then
        echo "[OK] Directory $dir exists"
    else
        echo "[FAIL] Directory $dir is missing"
        exit 1
    fi
done

# Check files
for file in "$INSTALL_PREFIX/bin/adi_colorimeter" \
            "$INSTALL_PREFIX/lib/adi_colorimeter/capture.so" \
            "$INSTALL_PREFIX/share/adi_colorimeter/adi_colorimeter.glade" \
            "$INSTALL_PREFIX/share/polkit-1/actions/org.adi.pkexec.adi_colorimeter.policy" \
            "$INSTALL_PREFIX/share/applications/adi-colorimeter.desktop" \
            "$INSTALL_PREFIX/share/icons/hicolor/16x16/apps/adi-colorimeter.png" \
            "$INSTALL_PREFIX/share/icons/hicolor/32x32/apps/adi-colorimeter.png" \
            "$INSTALL_PREFIX/share/icons/hicolor/64x64/apps/adi-colorimeter.png"; do
    if [ -f "$file" ]; then
        echo "[OK] File $file exists"
    else
        echo "[FAIL] File $file is missing"
        exit 1
    fi
done

# Check Python package - try import first, then check file location
if python3 -c "import adi_colorimeter" > /dev/null 2>&1; then
    echo "[OK] Python package adi_colorimeter installed (import check)"
elif ls /usr/lib/python3*/dist-packages/adi_colorimeter/__init__.py > /dev/null 2>&1; then
    echo "[OK] Python package adi_colorimeter installed (file check)"
else
    echo "[FAIL] Python package adi_colorimeter not found"
    exit 1
fi

echo "Installation verification successful!"
