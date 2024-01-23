PREFIX ?=/usr/local

.PHONY : all
all: capture.so adi-colorimeter.desktop lib/config.py org.adi.pkexec.adi_colorimeter.policy

capture.so: capture.c
	$(CC) -shared -o $@ $^ -liio -lm -Wall -Wextra -fPIC -std=gnu99 -pedantic -O3

%.desktop: %.desktop.in
	sed 's/@PREFIX@/$(subst /,\/,$(PREFIX))/' $+ > $@

%.policy: %.policy.in
	sed 's/@PREFIX@/$(subst /,\/,$(PREFIX))/' $+ > $@

%.py: %.py.in
	sed 's/@PREFIX@/$(subst /,\/,$(PREFIX))/' $+ > $@

install: all
	install -d $(PREFIX)/bin
	install -d $(PREFIX)/share/adi_colorimeter/
	install -d $(PREFIX)/lib/adi_colorimeter/
	install ./org.adi.pkexec.adi_colorimeter.policy /usr/share/polkit-1/actions/
	install ./adi_colorimeter $(PREFIX)/bin/
	install ./capture.so $(PREFIX)/lib/adi_colorimeter/
	install ./adi_colorimeter.glade $(PREFIX)/share/adi_colorimeter/

	xdg-icon-resource install --noupdate --size 16 ./icons/adi-colorimeter16.png adi-colorimeter
	xdg-icon-resource install --noupdate --size 32 ./icons/adi-colorimeter32.png adi-colorimeter
	xdg-icon-resource install --size 64 ./icons/adi-colorimeter64.png adi-colorimeter
	xdg-desktop-menu install adi-colorimeter.desktop

uninstall:
	rm -rf $(PREFIX)/share/adi_colorimeter
	rm -rf $(PREFIX)/bin/adi_colorimeter
	rm -rf $(PREFIX)/lib/adi_colorimeter
	rm /usr/share/polkit-1/actions/org.adi.pkexec.adi_colorimeter.policy

.PHONY : clean
clean:
	rm -f capture.so
	rm -f adi-colorimeter.desktop
	rm -f lib/config.py
	rm -f org.adi.pkexec.adi_colorimeter.policy
