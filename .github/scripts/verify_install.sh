#!/bin/bash
set -e

INSTALL_PREFIX="${1:-/usr}"

echo "Verifying installation..."

# Check directories
for dir in "$INSTALL_PREFIX/share/colorimeter" \
           "$INSTALL_PREFIX/lib/colorimeter" \
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
for file in "$INSTALL_PREFIX/bin/colorimeter" \
            "$INSTALL_PREFIX/lib/colorimeter/capture.so" \
            "$INSTALL_PREFIX/share/colorimeter/colorimeter.glade" \
            "$INSTALL_PREFIX/share/polkit-1/actions/org.colorimeter.pkexec.policy" \
            "$INSTALL_PREFIX/share/applications/colorimeter.desktop" \
            "$INSTALL_PREFIX/share/icons/hicolor/16x16/apps/colorimeter.png" \
            "$INSTALL_PREFIX/share/icons/hicolor/32x32/apps/colorimeter.png" \
            "$INSTALL_PREFIX/share/icons/hicolor/64x64/apps/colorimeter.png"; do
    if [ -f "$file" ]; then
        echo "[OK] File $file exists"
    else
        echo "[FAIL] File $file is missing"
        exit 1
    fi
done

# Check Python package - try import first, then check file location
if python3 -c "import colorimeter" > /dev/null 2>&1; then
    echo "[OK] Python package colorimeter installed (import check)"
elif ls /usr/lib/python3*/dist-packages/colorimeter/__init__.py > /dev/null 2>&1; then
    echo "[OK] Python package colorimeter installed (file check)"
else
    echo "[FAIL] Python package colorimeter not found"
    exit 1
fi

echo "Installation verification successful!"
