# Makefile for ltokenp

INSTALL_DIR= /usr/local/bin

CC= gcc -std=c99
CFLAGS= -Wall -Wextra -Wfatal-errors -O2
MYCFLAGS= $(CFLAGS) -Isrc

MYNAME= ltokenp
MYLIBS= src/liblua.a -lm -ldl

all:	bin test

bin:
	@$(MAKE) `uname`

test:
	./$(MYNAME) -v -s strip.lua strip.lua

install:
	cp $(MYNAME) $(INSTALL_DIR)

clean:
	rm -f $(MYNAME) src/*.o src/*.a

Linux:
	$(MAKE) build MYPLAT=linux MYLFLAGS=-Wl,-E

Darwin:
	$(MAKE) build MYPLAT=macosx MYLFLAGS=

build:
	$(MAKE) -C src $(MYPLAT) ALL_T=liblua.a MYCFLAGS=-I..
	$(CC) $(MYCFLAGS) -o $(MYNAME) $(MYNAME).c $(MYLIBS) $(MYLFLAGS)

.PHONY: all bin test install clean Linux Darwin build
