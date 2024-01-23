# CN0363 Colorimeter Application

Application to be used with the [EVAL-CN0363-PMDZ](https://wiki.analog.com/resources/eval/user-guides/eval-cn0363-pmdz)

## Documentation

- [CN0363 Colorimeter Application User Guide](https://wiki.analog.com/resources/tools-software/linux-software/colorimeter)


## Build Instructions
### Clone the repository
```
$ git clone https://github.com/analogdevicesinc/colorimeter.git
Cloning into 'colorimeter'...
remote: Counting objects: 65, done.
remote: Compressing objects: 100% (33/33), done.
remote: Total 65 (delta 13), reused 2 (delta 2), pack-reused 28
Unpacking objects: 100% (65/65), done.
Checking connectivity... done.
$ cd colorimeter/
```

### Install dependencies:
```
$ sudo apt install $(cat requirements.txt) -y
```

### Build app
```
$ make
cc -shared -o capture.so capture.c -liio -lm -Wall -Wextra -fPIC -std=gnu99 -pedantic -O3
$ sudo make install
install -d /usr/local/bin
install -d /usr/local/share/adi_colorimeter/
install -d /usr/local/lib/adi_colorimeter/
install -d /usr/local/share/adi_colorimeter/icons/
install ./org.adi.pkexec.adi_colorimeter.policy /usr/share/polkit-1/actions
install ./adi_colorimeter /usr/local/bin/
install ./capture.so /usr/local/lib/adi_colorimeter/
install ./adi_colorimeter.glade /usr/local/share/adi_colorimeter/
install ./icons/ADIlogo.png /usr/local/share/adi_colorimeter/icons/
xdg-icon-resource install --noupdate --size 16 ./icons/adi-colorimeter16.png adi-colorimeter
xdg-icon-resource install --noupdate --size 32 ./icons/adi-colorimeter32.png adi-colorimeter
xdg-icon-resource install --size 64 ./icons/adi-colorimeter64.png adi-colorimeter
xdg-desktop-menu install adi-colorimeter.desktop
```

### Install package with pip
- For Ubuntu <= 22.4, Debian <=11 (<=python3.10)
```
$ sudo python3 -m pip install .
```
- For Debian 12 (>=python3.11)
```
$ sudo apt install python3-venv
$ python3 -m venv env
$ source env/bin/activate
(env)$ sudo env/bin/python3 -m pip install .
(env)$ deactivate
```

## Uninstall
```
$ make clean
rm -f capture.so
rm -f adi-colorimeter.desktop
rm -f lib/config.py
rm -f org.adi.pkexec.adi_colorimeter.policy
$ sudo make uninstall
rm -rf /usr/local/share/adi_colorimeter
rm -rf /usr/local/bin/adi_colorimeter
rm -rf /usr/local/lib/adi_colorimeter
rm /usr/share/polkit-1/actions/org.adi.pkexec.adi_colorimeter.policy
```
- For Ubuntu <= 22.4, Debian <=11 (<=python3.10)
```
$ sudo python3 -m pip uninstall adi_colorimeter
Found existing installation: adi-colorimeter 1.0
Uninstalling adi-colorimeter-1.0:
  Would remove:
    /usr/local/lib/python3.10/dist-packages/adi_colorimeter-1.0.dist-info/*
    /usr/local/lib/python3.10/dist-packages/adi_colorimeter/*
Proceed (Y/n)? Y
  Successfully uninstalled adi-colorimeter-1.0
```
- For Debian 12 (>=python3.11)
```
$ source env/bin/activate
(env)$ sudo env/bin/pip uninstall adi_colorimeter
(env)$ deactivate
```
