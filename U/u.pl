#!/usr/bin/env -S perl -CS -l
use strict;
use warnings;
print(map {chr hex} @ARGV)
