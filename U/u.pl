#!/usr/bin/env -S perl -CS -l
use strict;
use warnings;
print(map {chr int hex} @ARGV)
