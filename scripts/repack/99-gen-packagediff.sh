#!/bin/sh

comm --nocheck-order -3 installed-software installed-software2 | sed 's/^\t//' >files/var/tmp/additional-software


