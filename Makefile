BINDIR ?= /usr/bin
LIBEXECDIR ?= /usr/libexec
MANDIR ?= /usr/share/man/man1

.PHONY: build check format install uninstall clean

build:
	dune build --profile=release @install

check:
	dune build @check

install:
	mkdir -p $(DESTDIR)$(LIBEXECDIR)
	cp _build/default/bin/xcp_featured.exe $(DESTDIR)$(LIBEXECDIR)/xcp-featured

uninstall:
	rm -f $(DESTDIR)$(LIBEXECDIR)/xcp-featured

format:
	dune build @fmt --auto-promote

clean:
	dune clean
