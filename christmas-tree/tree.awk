function sgn(v) {
	if (v < 0) {return -1}
	if (v > 0) {return 1}
	return 0
}

function min(a, b) {
	return a < b ? a : b
}

function f() {
	n = 30
	s = "*"
	printf("\033[2J\033[1;1H") # clear entire screen and goto (1,1)
	print("\033[32m") # green
	for (i = 0; i < n; ++i) {
		printf("%*s%s\n", n-i, "", s)
		s = s "**"
		system("sleep 0.02")
	}
	print(s)
	printf("\033[31m") # red
	printf("%*s\n", n+1, "||")
	printf("%*s\n", n+1, "||")
	for (i = 0; i < 128; ++i) {
		y = min(n+2, 2 + int(n - rand() * (n-i/4)))
		x = 31 + int(rand() * (y - 2)) * sgn(2 * rand() - 1)
		printf("\033["(33 + int(rand() * 5))"m") # color
		printf("\033["y";"x"Ho") # goto (x,y)
		system("sleep 0.02")
	}
	printf("\033["(n+5)";"1"H") # goto (x,y)
}

BEGIN {
	srand()
	f()
}
