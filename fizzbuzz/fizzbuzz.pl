#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

say for map {'fizz' x ($_%3==0) . 'buzz' x ($_%5==0) || $_} 1..100
