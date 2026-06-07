#!/usr/bin/perl
use strict;
use warnings;

# --- Config ----------------------------------------------------------
my $duration = 3;
my $font     = 'DejaVu Sans 24';
my $monitor  = '-1';     # -1 = under cursor, -4 = focused window, -2 = focused monitor
# ---------------------------------------------------------------------

# Battery line
my $bat = "";
if (my $raw = `acpi 2>/dev/null`) {
    if ($raw =~ /:\s*([^,]+),\s*(\d+%)/) {
        my %sym = (
            Full           => '█',
            Discharging    => '▼',
            Charging       => '▲',
            'Not charging' => '■',
            Unknown        => '?',
        );
        my $s = $sym{$1} // '?';
        $bat = "🔋 $s $2";
    }
}

# Time + uptime
chomp(my $time = `date '+%a %Y-%m-%d %H:%M:%S'`);
chomp(my $up   = `uptime`);
$up =~ s/^.{13}//;       # cut -c 14-
my $upline = "up $up";

my $msg = join "\n", grep { length } ($time . '  ' . $bat, $upline);

# Show — list-form exec avoids shell entirely
exec 'timeout' , '-p', '-s', 2, $duration,
     'rofi', '-e', $msg,
     '-normal-window',
     '-class', 'popup',
     '-monitor',   $monitor,
     '-theme-str', 'textbox { horizontal-align: 0.5; }',
     '-theme-str', qq{textbox { font: "$font"; }};
