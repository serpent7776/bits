#!/usr/bin/env tclsh

set pattern [lindex $argv 0]
set files [glob $pattern]
foreach {l r} [exec ls {*}$files] {
	if {[catch {exec zcmp -s $l $r} err]} {
		puts "$l $r differ"
		exec vim -d $l $r <@ stdin >@ stdout 2>@ stderr
	}
}

