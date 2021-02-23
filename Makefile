PREFIX ?=/usr/local
DESTDIR ?=/

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
	install -d $(DESTDIR)$(PREFIX)/bin
	install -d $(DESTDIR)$(PREFIX)/share/adi_colorimeter/
	install -d $(DESTDIR)$(PREFIX)/lib/adi_colorimeter/
	install ./org.adi.pkexec.adi_colorimeter.policy /usr/share/polkit-1/actions 
	install ./adi_colorimeter $(DESTDIR)$(PREFIX)/bin/
	install ./capture.so $(DESTDIR)$(PREFIX)/lib/adi_colorimeter/
	install ./adi_colorimeter.glade $(DESTDIR)$(PREFIX)/share/adi_colorimeter/
	./setup.py install --prefix=$(PREFIX) --root=$(DESTDIR)

	xdg-icon-resource install --noupdate --size 16 ./icons/adi-colorimeter16.png adi-colorimeter
	xdg-icon-resource install --noupdate --size 32 ./icons/adi-colorimeter32.png adi-colorimeter
	xdg-icon-resource install --size 64 ./icons/adi-colorimeter64.png adi-colorimeter
	xdg-desktop-menu install adi-colorimeter.desktop

.PHONY : clean
clean:
	rm -f capture.so
	rm -f adi-colorimeter.desktop
	rm -f lib/config.py
	rm -f org.adi.pkexec.adi_colorimeter.policy
