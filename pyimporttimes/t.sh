#!/bin/sh
sort -n -k 3 -r | awk '
function max(a,b) {
	return a>b ? a : b;
}
{
	if ($3 ~ /[0-9]+/) {
		total_self_time += $3
		lines[NR] = $0
		sub("[ ]+([_a-zA-Z0-9\\.]+$)", " "$7, lines[NR])
		self_times[NR] = $3
		maxlen = max(maxlen, length(lines[NR]))
	} else {
		print $0
	}
}
END {
	for (i = 1; i <= NR; i++) {
		if (lines[i] != "") {
			ratio = self_times[i] / total_self_time
			bar=""
			for(j=0; j<ratio*80; j++) bar=bar"#"
			f=sprintf("%%-%ds | %%6.2f%%%% %%s\n", maxlen+2)
			printf f, lines[i], ratio*100, bar
			}
		}
}'
