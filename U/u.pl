#!/usr/bin/env -S perl -CS -l
use strict;
use warnings;
print map {chr hex} map {my $s=$_; $s =~ s/^U\+// ;$s} @ARGV
