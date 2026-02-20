PREFIX ?= /usr/local
DESTDIR ?=
DEB_BUILD ?=0# default: manual install mode

.PHONY : all
all: capture.so colorimeter.desktop lib/config.py org.colorimeter.pkexec.policy

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
	install -d $(DESTDIR)$(PREFIX)/share/colorimeter/
	install -d $(DESTDIR)$(PREFIX)/lib/colorimeter/
	install -d $(DESTDIR)/usr/share/polkit-1/actions/
	install ./org.colorimeter.pkexec.policy $(DESTDIR)/usr/share/polkit-1/actions/
	install ./colorimeter $(DESTDIR)$(PREFIX)/bin/
	install ./capture.so $(DESTDIR)$(PREFIX)/lib/colorimeter/
	install ./colorimeter.glade $(DESTDIR)$(PREFIX)/share/colorimeter/
ifeq ($(DEB_BUILD),0)
	xdg-icon-resource install --novendor --noupdate --size 16 ./icons/colorimeter16.png colorimeter
	xdg-icon-resource install --novendor --noupdate --size 32 ./icons/colorimeter32.png colorimeter
	xdg-icon-resource install --novendor --size 64 ./icons/colorimeter64.png colorimeter
	xdg-desktop-menu install --novendor colorimeter.desktop
else
	install -d $(DESTDIR)$(PREFIX)/share/applications/
	install -m 644 ./colorimeter.desktop \
		$(DESTDIR)/usr/share/applications/

	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/
	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/
	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/64x64/apps/
	install -m 644 ./icons/colorimeter16.png \
		$(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/colorimeter.png
	install -m 644 ./icons/colorimeter32.png \
		$(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/colorimeter.png
	install -m 644 ./icons/colorimeter64.png \
		$(DESTDIR)$(PREFIX)/share/icons/hicolor/64x64/apps/colorimeter.png
endif

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/share/colorimeter
	rm -rf $(DESTDIR)$(PREFIX)/bin/colorimeter
	rm -rf $(DESTDIR)$(PREFIX)/lib/colorimeter
	rm -f $(DESTDIR)/usr/share/polkit-1/actions/org.colorimeter.pkexec.policy
ifeq ($(DEB_BUILD),0)
	xdg-icon-resource uninstall --novendor --size 16 colorimeter
	xdg-icon-resource uninstall --novendor --size 32 colorimeter
	xdg-icon-resource uninstall --novendor --size 64 colorimeter
	xdg-desktop-menu uninstall --novendor colorimeter.desktop
else
	rm -f $(DESTDIR)$(PREFIX)/share/applications/colorimeter.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/colorimeter.png
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/colorimeter.png
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/64x64/apps/colorimeter.png
endif


.PHONY : clean
clean:
	rm -f capture.so
	rm -f colorimeter.desktop
	rm -f lib/config.py
	rm -f org.colorimeter.pkexec.policy
