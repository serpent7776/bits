#!/usr/bin/env -S awk -f
BEGIN {$0="12345678"; gsub(".", "☀️, "); sub(", $", ""); printf "[ %s ]", $0}
