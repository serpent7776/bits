#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

say for map {($_, 'fizz', 'buzz', 'fizzbuzz')[($_%3==0) + 2*($_%5==0)]} 1..100
