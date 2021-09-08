#!/usr/bin/env sh
PROGRAM=xbps-freedom
PREFIX=/usr
install -m 644 -o root -g root -t ${PREFIX}/share/man/man1/ ${PROGRAM}.1
install -m 755 -o root -g root -t ${PREFIX}/bin/ ${PROGRAM}.pl
