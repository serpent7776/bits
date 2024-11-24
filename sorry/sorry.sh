#!/bin/sh
# Different ways to say sorry 1000 times

ruby -e 'print(Array.new(1000, "Sorry\n").join(""))'
awk -e 'BEGIN{for(i=0;i<1000;i++)print("Sorry")}'
sh -c 'for i in `seq 1000`; do echo Sorry; done'
lua -e 'print(string.rep("Sorry\n", 1000))'
sh -c 'printf "%0.sSorry\n" $(seq 1000)'
perl -e 'print "Sorry\n"x1000'
bqn -e '•Out¨1000/⟨"Sorry"⟩'
R -q -s --no-save <<eof
cat(strrep("Sorry\n", 1000))
eof
tclsh <<eof
puts [string repeat "Sorry\n" 1000]
eof
ngnk <<eof
`0:1000#,$`Sorry
eof
