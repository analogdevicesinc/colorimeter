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
install -d /usr/local/share/colorimeter/
install -d /usr/local/lib/colorimeter/
install -d /usr/share/polkit-1/actions/
install ./org.colorimeter.pkexec.policy /usr/share/polkit-1/actions/
install ./colorimeter /usr/local/bin/
install ./capture.so /usr/local/lib/colorimeter/
install ./colorimeter.glade /usr/local/share/colorimeter/
xdg-icon-resource install --noupdate --size 16 ./icons/colorimeter16.png colorimeter
xdg-icon-resource install --noupdate --size 32 ./icons/colorimeter32.png colorimeter
xdg-icon-resource install --size 64 ./icons/colorimeter64.png colorimeter
xdg-desktop-menu install colorimeter.desktop
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
rm -f colorimeter.desktop
rm -f lib/config.py
rm -f org.colorimeter.pkexec.policy
$ sudo make uninstall
rm -rf /usr/local/share/colorimeter
rm -rf /usr/local/bin/colorimeter
rm -rf /usr/local/lib/colorimeter
rm /usr/share/polkit-1/actions/org.colorimeter.pkexec.policy
```
- For Ubuntu <= 22.4, Debian <=11 (<=python3.10)
```
$ sudo python3 -m pip uninstall colorimeter
Found existing installation: colorimeter 1.0
Uninstalling colorimeter-1.0:
  Would remove:
    /usr/local/lib/python3.10/dist-packages/colorimeter-1.0.dist-info/*
    /usr/local/lib/python3.10/dist-packages/colorimeter/*
Proceed (Y/n)? Y
  Successfully uninstalled colorimeter-1.0
```
- For Debian 12 (>=python3.11)
```
$ source env/bin/activate
(env)$ sudo env/bin/pip uninstall colorimeter
(env)$ deactivate
```
