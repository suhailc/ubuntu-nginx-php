#!/bin/sh

comm --nocheck-order -3 installed-software installed-software2 | sed 's/^\t//' >/tmp/base-installed-software


