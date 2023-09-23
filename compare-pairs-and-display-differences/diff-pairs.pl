#!/usr/bin/perl

my @a = split /\n/, `ls $ARGV[0] | xargs -n 2`;
foreach my $l (@a) {
	system('zcmp -s ' .  $l);
	if ($? != 0) {
		print "$l differ\n";
		system('vim -d ' . $l);
	}
}
