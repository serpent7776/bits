# run it like `echo | sed -f sunshine.sed`
s/.*/☀️, /
h
G
1,$s/\n//
h
G
1,$s/\n//
h
G
1,$s/\n//
s/, $//
s/.*/[ & ]/
