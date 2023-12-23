#!/usr/bin/env perl
use warnings;

$e='\033[';
$clr='\033[2J';
$gg='\033[1;1H';
$gr='\033[32m';
$re='\033[31m';
$p='print';
$P='printf';
$n='\n';
$w='system("sleep 0.02")';
$rd='rand()';
$i='int';
sub f {($F,$A)=@_;$A||='';return "function $F($A)"}
sub r {return "return @_"}
sub v {($R,$L)=@_; return "$R = $L"}
sub l {($M)=@_;return "for (i = 0; i < $M; ++i)"}
sub go {($X,$Y,$T)=@_;$H='H';return qq/$P("$e$Y;$X$H$T")/}
sub co {($C)=@_;$M='m';return qq/$P("$e$C$M")/}
print qq@${\f('sgn', 'v')} {
	if (v < 0) {${\r(-1)}}
	if (v > 0) {${\r(1)}}
	${\r(0)}
}

${\f('min', 'a, b')} {
	${\r('a < b ? a : b')}
}

${\f('f')} {
	${\v('n', 30)}
	${\v('s', q/"*"/)}
	$P("$clr$gg") # clear entire screen and goto (1,1)
	$p("$gr") # green
	${\l('n')} {
		$P("%*s%s$n", n-i, "", s)
		s = s "**"
		# $w
	}
	$p(s)
	$P("$re") # red
	$P("%*s$n", n+1, "||")
	$P("%*s$n", n+1, "||")
	${\l(128)} {
		y = min(n+2, 2 + $i(n - $rd * (n-i/4)))
		x = 31 + $i($rd * (y - 2)) * sgn(2 * $rd - 1)
		${\co(qq/"(33 + $i($rd * 5))"/)} # color
		${\go(q/"x"/, q/"y"/, "o")} # goto (x,y)
		# $w
	}
	${\go(q/"1"/, q/"(n+5)"/, '')} # goto (x,y)
}

BEGIN {
	srand()
	f()
}
@;
