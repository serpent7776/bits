#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

say for map {('', 'fizz')[$_%3==0].('', 'buzz')[$_%5==0] || $_} 1..100
