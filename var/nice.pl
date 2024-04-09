#!/usr/bin/env perl
use strict;
use warnings;

my@a=sub{my@a=@_;
map{(-10, -12, 86, 56, -82, -5, -82, 1, 73, 54, -13, -70)[$_]+$a[$_]} 0..11
}->((unpack("C*", 'rm -rf')) x 2);my@w=(0x64, 0x61, 0x79);
print eval "'" . pack("C*", @a) . pack("C*", @w) . "\n'";
