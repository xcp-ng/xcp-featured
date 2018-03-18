BINDIR ?= /usr/bin
SBINDIR ?= /usr/sbin
MANDIR ?= /usr/share/man/man1

.PHONY: build install uninstall clean

build:
	jbuilder build @install

install:
	mkdir -p $(DESTDIR)$(SBINDIR)
	cp _build/default/bin/xcp_featured.exe $(DESTDIR)$(SBINDIR)/v6d

uninstall:
	rm -f $(DESTDIR)$(SBINDIR)/v6d

clean:
	jbuilder clean
