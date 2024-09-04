#!/usr/bin/env perl
use strict;
use warnings;

my $q=0;
sub slam {my ($a, $e) = @_; push @$a, $e; return @$a;}
sub f{my @a=caller 1; return \@a;}
sub programming {return caller 0}
sub is {return map {$_->[3]} (\@_,f)}
sub really {return map {substr $_, 1} slam(\@_, substr((caller(0))[3], $q++))}
sub fun {return slam \@_, "fun"}

$,=" ";
print fun really really really really really really is programming
