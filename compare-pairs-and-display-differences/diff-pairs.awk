#!/usr/bin/env awk

BEGIN {
	cmd=sprintf("ls %s | xargs -n 2", ARGV[1]);
	while (cmd | getline line) {
		if (system(sprintf("zcmp -s %s", line))) {
			printf("%s differ\n", line);
			system(sprintf("vim -d %s", line))
		}
	}
}
