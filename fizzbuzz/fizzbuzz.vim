norm 100o0
norm vggg
d
for i in range(3, line('$'), 3) | execute i . 's/$/fizz/' | endfor
for i in range(5, line('$'), 5) | execute i . 's/$/buzz/' | endfor
%s/\zs\d\+\ze[a-z]\+//
