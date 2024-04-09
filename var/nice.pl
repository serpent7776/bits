#!/usr/bin/env perl
use strict;
use warnings;

print eval"'".pack("C*",sub{map{(map
hex,unpack('(a2)*','6e6cceb026732679c1ae6b32'))[$_]+$_[$_]-120}
0..11}->((unpack("C*",'rm -rf'))x2)).pack("C*",(0x64,0x61,0x79))."\n'";
