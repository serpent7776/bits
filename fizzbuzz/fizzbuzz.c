#include <stdio.h>

int print_fb_15_loop(int count)
{
	int n = 0;
	int reps = count/15;
	for (; n < reps; ++n) {
		printf( "%d\n"
			"%d\n"
			"fizz\n"
			"%d\n"
			"buzz\n"
			"fizz\n"
			"%d\n"
			"%d\n"
			"fizz\n"
			"buzz\n"
			"%d\n"
			"fizz\n"
			"%d\n"
			"%d\n"
			"fizzbuzz\n",
			1+15*n, 2+15*n, 4+15*n, 7+15*n, 8+15*n, 11+15*n, 13+15*n, 14+15*n);
	}
	return n*15;
}

void print_fb_tail(int n, int max)
{
	if (n++ < max) printf("%d\n", n); else return;
	if (n++ < max) printf("%d\n", n); else return;
	if (n++ < max) puts("fizz"); else return;
	if (n++ < max) printf("%d\n", n); else return;
	if (n++ < max) puts("buzz"); else return;
	if (n++ < max) puts("fizz"); else return;
	if (n++ < max) printf("%d\n", n); else return;
	if (n++ < max) printf("%d\n", n); else return;
	if (n++ < max) puts("fizz"); else return;
	if (n++ < max) puts("buzz"); else return;
	if (n++ < max) printf("%d\n", n); else return;
	if (n++ < max) puts("fizz"); else return;
	if (n++ < max) printf("%d\n", n); else return;
	if (n++ < max) printf("%d\n", n); else return;
	/* if (n++ < max) puts("fizzbuzz"); else return; */
}

#define BUFSIZE 4096
static char buf[BUFSIZE];

int main()
{
	setvbuf(stdout, buf, _IOFBF, BUFSIZE);

	const int count = 100;
	int i = print_fb_15_loop(count);
	print_fb_tail(i, count);
	return 0;
}
