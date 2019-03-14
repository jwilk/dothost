# Copyright © 2012-2019 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

PYTHON = python3

PREFIX = /usr/local
DESTDIR =

bindir = $(PREFIX)/bin
mandir = $(PREFIX)/share/man

.PHONY: all
all: ;

.PHONY: install
install: dothost
	# executable:
	install -d $(DESTDIR)$(bindir)
	python_exe=$$($(PYTHON) -c 'import sys; print(sys.executable)') && \
	sed \
		-e "1 s@^#!.*@#!$$python_exe@" \
		-e "s#^basedir = .*#basedir = '$(basedir)/'#" \
		$(<) > $(<).tmp
	install $(<).tmp $(DESTDIR)$(bindir)/$(<)
	rm $(<).tmp
	# manual page:
	install -d $(DESTDIR)$(mandir)/man1
	install -p -m644 doc/$(<).1 $(DESTDIR)$(mandir)/man1/

network =
maybe-test-net = $(and $(network),DOTHOST_TEST_NETWORK=1)

.PHONY: test
test: dothost
	$(maybe-test-net) prove -v

.PHONY: test-installed
test-installed: $(or $(shell command -v dothost;),$(bindir)/dothost)
	$(maybe-test-net) DOTHOST_TEST_TARGET=dothost prove -v

.PHONY: clean
clean:
	rm -f *.tmp

.error = GNU make is required

# vim:ts=4 sts=4 sw=4 noet
