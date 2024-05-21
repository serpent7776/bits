#!/usr/bin/env -S perl -na
use strict;
use warnings;
use v5.38;

sub isat {
	my ($arr, $idx, $val) = @_;
	return scalar @$arr > $idx && $arr->[$idx] eq $val;
}

sub label {
	my ($cell, $text) = @_;
	say qq/label $cell = "$text"/;
}

our $command;
our %d;

if (m#Performance counter stats for '([^']+)'#) { $command = $1; }
if (isat(\@F, 1, 'context-switches:u')) { $d{$command}{'context_switches'} = $F[0]; }
if (isat(\@F, 1, 'cpu-migrations:u')) { $d{$command}{'cpu_migrations'} = $F[0]; }
if (isat(\@F, 1, 'page-faults:u')) { $d{$command}{'page_faults'} = $F[0]; }
if (isat(\@F, 1, 'cycles:u')) { $d{$command}{'cycles'} = $F[0]; }
if (isat(\@F, 1, 'instructions:u')) { $d{$command}{'instructions'} = $F[0]; }
if (isat(\@F, 4, 'insn') && isat(\@F, 5, 'per') && isat(\@F, 6, 'cycle')) { $d{$command}{'insn_per_cycle'} = $F[0]; }
if (isat(\@F, 1, 'branches:u')) { $d{$command}{'branches'} = $F[0]; }
if (isat(\@F, 1, 'branch-misses:u')) { $d{$command}{'branch_misses'} = $F[0]; }

if (isat(\@F, 4, 'tma_backend_bound')) { $d{$command}{'backend_bound'} = $F[2]; }
if (isat(\@F, 3, 'tma_bad_speculation')) { $d{$command}{'bad_speculation'} = $F[1]; }
if (isat(\@F, 3, 'tma_frontend_bound')) { $d{$command}{'frontend_bound'} = $F[1]; }
if (isat(\@F, 3, 'tma_retiring')) { $d{$command}{'retiring'} = $F[1]; }

if (isat(\@F, 1, 'seconds') && isat(\@F, 2, 'time')) { $d{$command}{'real'} = $F[0]; }
if (isat(\@F, 1, 'seconds') && isat(\@F, 2, 'user')) { $d{$command}{'user'} = $F[0]; }
if (isat(\@F, 1, 'seconds') && isat(\@F, 2, 'sys')) { $d{$command}{'sys'} = $F[0]; }

END {
	my @keys = (
		'context_switches', 'cpu_migrations', 'page_faults', 'cycles', 'instructions', 'insn_per_cycle', 'branches', 'branch_misses',
		'backend_bound', 'bad_speculation', 'frontend_bound', 'retiring',
		'real', 'user', 'sys',
	);

	label('A0', 'command');
	my $col = 'B';
	foreach my $k (@keys) {
		label($col++ . 0, $k);
	}
	my $N = 0;
	foreach my $command (keys(%d)) {
		$col = 'A';
		label($col++ . ++$N, $command);
		foreach my $k (@keys) {
			label($col++ . $N, $d{$command}{$k});
		}
	}
	$col = 'A';
	say "format ${\$col++} 18 2 0";
	for my $k (@keys) {
		say "format ${\$col++} 18 2 0";
	}
	say 'goto A0';
	say 'autofit A';
	say 'freeze A';
	say 'goto A0';
}
