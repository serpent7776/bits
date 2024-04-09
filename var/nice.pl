#!/usr/bin/env perl
use strict;
use warnings;

print eval "'" . pack("C*", sub{
map{(-10, -12, 86, 56, -82, -5, -82, 1, 73, 54, -13, -70)[$_]+$_[$_]} 0..11
}->((unpack("C*", 'rm -rf')) x 2)) . pack("C*", (0x64, 0x61, 0x79)) . "\n'";
