#!/usr/bin/env perl
use strict;
use warnings;
use v5.38;

sub is_palindrome { $_[0] eq join '', reverse split //, $_[0] }
say is_palindrome($ARGV[0])+0
