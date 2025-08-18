PREFIX ?= /usr/local
DESTDIR ?=
DEB_BUILD ?=0# default: manual install mode

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
	install -d $(DESTDIR)/usr/share/polkit-1/actions/
	install ./org.adi.pkexec.adi_colorimeter.policy $(DESTDIR)/usr/share/polkit-1/actions/
	install ./adi_colorimeter $(DESTDIR)$(PREFIX)/bin/
	install ./capture.so $(DESTDIR)$(PREFIX)/lib/adi_colorimeter/
	install ./adi_colorimeter.glade $(DESTDIR)$(PREFIX)/share/adi_colorimeter/
ifeq ($(DEB_BUILD),0)
	xdg-icon-resource install --noupdate --size 16 ./icons/adi-colorimeter16.png adi-colorimeter
	xdg-icon-resource install --noupdate --size 32 ./icons/adi-colorimeter32.png adi-colorimeter
	xdg-icon-resource install --size 64 ./icons/adi-colorimeter64.png adi-colorimeter
	xdg-desktop-menu install adi-colorimeter.desktop
else
	install -d $(DESTDIR)$(PREFIX)/share/applications/
	install -m 644 ./adi-colorimeter.desktop \
		$(DESTDIR)/usr/share/applications/

	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/
	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/
	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/64x64/apps/
	install -m 644 ./icons/adi-colorimeter16.png \
		$(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/adi-colorimeter.png
	install -m 644 ./icons/adi-colorimeter32.png \
		$(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/adi-colorimeter.png
	install -m 644 ./icons/adi-colorimeter64.png \
		$(DESTDIR)$(PREFIX)/share/icons/hicolor/64x64/apps/adi-colorimeter.png
endif

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/share/adi_colorimeter
	rm -rf $(DESTDIR)$(PREFIX)/bin/adi_colorimeter
	rm -rf $(DESTDIR)$(PREFIX)/lib/adi_colorimeter
	rm -f $(DESTDIR)/usr/share/polkit-1/actions/org.adi.pkexec.adi_colorimeter.policy
ifeq ($(DEB_BUILD),0)
	xdg-icon-resource uninstall --size 16 adi-colorimeter
	xdg-icon-resource uninstall --size 32 adi-colorimeter
	xdg-icon-resource uninstall --size 64 adi-colorimeter
	xdg-desktop-menu uninstall adi-colorimeter.desktop
else
	rm -f $(DESTDIR)$(PREFIX)/share/applications/adi-colorimeter.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/adi-colorimeter.png
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/adi-colorimeter.png
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/64x64/apps/adi-colorimeter.png
endif


.PHONY : clean
clean:
	rm -f capture.so
	rm -f adi-colorimeter.desktop
	rm -f lib/config.py
	rm -f org.adi.pkexec.adi_colorimeter.policy
