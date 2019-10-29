# CN0363 Colorimeter Application

Application to be used with the [EVAL-CN0363-PMDZ](https://wiki.analog.com/resources/eval/user-guides/eval-cn0363-pmdz)

## Documentation

- [CN0363 Colorimeter Application User Guide](https://wiki.analog.com/resources/tools-software/linux-software/colorimeter)


## Build Instructions

``` 
$ git clone https://github.com/analogdevicesinc/colorimeter.git
Cloning into 'colorimeter'...
remote: Counting objects: 65, done.
remote: Compressing objects: 100% (33/33), done.
remote: Total 65 (delta 13), reused 2 (delta 2), pack-reused 28
Unpacking objects: 100% (65/65), done.
Checking connectivity... done.
$ make
cc -shared -o capture.so capture.c -liio -lm -Wall -Wextra -fPIC -std=gnu99 -pedantic -O3
$ make install
sed 's/@PREFIX@/\/usr\/local/' adi-colorimeter.desktop.in > adi-colorimeter.desktop
sed 's/@PREFIX@/\/usr\/local/' lib/config.py.in > lib/config.py
root@analog:~/colorimeter# make install
install -d //usr/local/bin
install -d //usr/local/share/adi_colorimeter/
install -d //usr/local/lib/adi_colorimeter/
install ./adi_colorimeter //usr/local/bin/
install ./capture.so //usr/local/lib/adi_colorimeter/
install ./adi_colorimeter.glade //usr/local/share/adi_colorimeter/
./setup.py install --prefix=/usr/local --root=/
running install
running build
running build_py
copying lib/config.py -> build/lib.linux-armv7l-2.7/adi_colorimeter
running install_lib
copying build/lib.linux-armv7l-2.7/adi_colorimeter/config.py -> /usr/local/lib/python2.7/dist-packages/adi_colorimeter
byte-compiling /usr/local/lib/python2.7/dist-packages/adi_colorimeter/config.py to config.pyc
running install_egg_info
Removing /usr/local/lib/python2.7/dist-packages/adi_colorimeter-1.0-py2.7.egg-info
Writing /usr/local/lib/python2.7/dist-packages/adi_colorimeter-1.0-py2.7.egg-info
xdg-icon-resource install --noupdate --size 16 ./icons/adi-colorimeter16.png adi-colorimeter
xdg-icon-resource install --noupdate --size 32 ./icons/adi-colorimeter32.png adi-colorimeter
xdg-icon-resource install --size 64 ./icons/adi-colorimeter64.png adi-colorimeter
xdg-desktop-menu install adi-colorimeter.desktop
```
