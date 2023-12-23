#!/usr/bin/env perl
use warnings;

                                                                             $
                                                                             e=
                                                                           '\033'.
                                                                         '[';$clr=
                                                                       '\033[2J';$gg
                                                                     ='\033[1;1H';$gr
                                                                  ='\033[32m';$re='\033'.
                                                              '[31m';$p='print';$P='printf';
                                                            $n='\n';$w='system("sleep 0.02")';
                                                          $rd='rand()';$i='int';sub f {($F,$A)=
                                                        @_;$A||='';return "function $F($A)"} sub
                                                    r {return "return @_"} sub v {($R,$L)=@_; return
                                                  "$R = $L"} sub l {($M)=@_;return "for (i = 0; i < $M;".
                                                 " ++i)"} sub go {($X,$Y,$T)=@_;$H='H';return qq/$P("$e$Y;/.
                                                qq/$X$H$T")/} sub co {($C)=@_;$M='m';return qq/$P("$e$C$M")/}
                                               print "${\f('sgn', 'v')}".qq@ {\n\tif (v < 0) {${\r(-1)}}\n\tif@.
                                             qq@ (v > 0)@.  " {${\r(1)}}\n\t".qq@${\r(0)}\n}\n\n${\f('min', 'a, b')}@
                                           .qq@ {\n\t${\r('a < b ? a : b')}\n}\n\n${\f('f')}@.qq@ {\n\t${\v('n', 30)}@
                                         .qq@\n\t${\v('s', q/"*"/)}\n\t$P("$clr$gg") # clear entire screen@.qq@ and goto@
                                       .qq@ (1,1)\n\t$p("@.qq@$gr") # green\n\t${\l('n')} {\n\t\t$P("%*s%s$n", n-i, "", s)@.
                                     qq@\n\t\ts = s "**"\n\t\t$w@.qq@\n\t}\n\t$p(s)\n\t$P("$re") # red\n\t$P("%*s$n", n+1, "||"@
                                  .qq@)\n\t$P("%*s$n", n+1, "||")\n\t${\l(128)} {\n\t\ty = min@.qq@(n+2, 2 + $i(n - $rd * (n-i/4)))@
                                 .qq@\n\t\tx = 31 + $i($rd * (y - 2)) * @.qq@sgn(2 * $rd - 1)\n\t\t${\co(qq/"(33 + $i($rd * 5))"/)}@.
                               qq@ # color\n\t\t${\go(q/"x"/, q/"y"/, "o")} # goto (x,y)\n\t\t$w\n\t}\n\t${\go(q/"1"/, q/"(n+5)"/, '')}@.
                                                                        " # goto ".
                                                                        "(x,y)\n}".
                                                                        "\n\nBEGIN ".
                                                                        "{\n\tsrand".
                                                                        "()\n\t"."f".
                                                                        "()\n}\n" ;
