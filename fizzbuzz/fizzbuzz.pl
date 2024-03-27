#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

say 'fizz' x !($_%3) . 'buzz' x !($_%5) || $_ for 1..100
