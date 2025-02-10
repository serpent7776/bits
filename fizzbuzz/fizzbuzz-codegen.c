#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>

int usage(void)
{
	puts("./fizzbuzz N");
	puts("Prints fizzbuzz for numbers 1-N by generating x86 code at runtime.");
	return 1;
}

/* https://wiki.osdev.org/X86-64_Instruction_Encoding#REX_prefix */
static const unsigned char REX = 0b0100;
static const unsigned char REX_W = REX << 4 | 0b1000;
static const unsigned char REX_R = REX << 4 | 0b0100;
static const unsigned char REX_X = REX << 4 | 0b0010;
static const unsigned char REX_B = REX << 4 | 0b0001;
static const unsigned char REX_WB = REX_W | REX_B;
static const unsigned char MOV_R12 = 0xBC;
static const unsigned char MOV_RDI = 0xBF;
static const unsigned char MOV_RAX = 0xB8;
static const unsigned char MOV_RDI_RAX[] = {0x89, 0xC7};
static const unsigned char CALL_R12[] = {0xFF, 0xD4};
static const unsigned char CALL_RAX[] = {0xFF, 0xD0};
static const unsigned char PUSH_R12[] = {0x41, 0x54};
static const unsigned char POP_R12[] = {0x41, 0x5c};
static const unsigned char RET = 0xC3;
static const unsigned char NOP = 0x90;

static const char* fizz = "fizz";
static const char* buzz = "buzz";
static const char* fizzbuzz = "fizzbuzz";

static char numbuf[21] = {};
char* itoa(size_t num)
{
    if (num == 0) {
        numbuf[0] = '0';
        numbuf[1] = '\0';
        return numbuf;
    }

    char* m = &numbuf[20];
    *(m--) = 0;
    while (num > 0) {
        *(m--) = '0' + (num % 10);
        num /= 10;
    }

    return m+1;
}

int main(int argc, char *argv[])
{
	if (argc < 2) return usage();

	const int n = atoi(argv[1]);
	if (n == 0) exit(0);
	if (n < 0) exit(1);

	const size_t pagesize = sysconf(_SC_PAGESIZE);
	if (pagesize == (size_t)-1) {
		perror("sysconf");
		exit(EXIT_FAILURE);
	}

	const size_t bytes = 16 + 40 * n + 3;
	const size_t num_pages = bytes / pagesize + 1;

	unsigned char* page = mmap(NULL, pagesize * num_pages, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (page == MAP_FAILED) {
		perror("mmap");
		exit(EXIT_FAILURE);
	}

	unsigned char* m = page;
	*(m++) = NOP; *(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
	*(m++) = PUSH_R12[0]; *(m++) = PUSH_R12[1];
	*(m++) = REX_WB; *(m++) = MOV_R12; *(int (**)(const char *))m = puts; m+=8;
	for (int i = 1; i <= n; i++)
	{
		const int f = i % 3 == 0;
		const int b = i % 5 == 0;
		switch((b << 1) | f)
		{
			case 0b00:
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = REX_W; *(m++) = MOV_RAX; *(char*(**)(size_t))m = itoa; m+=8;
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = REX_W; *(m++) = MOV_RDI; *(size_t*)m = i; m+=8;
				*(m++) = CALL_RAX[0]; *(m++) = CALL_RAX[1];
				*(m++) = REX_W; *(m++) = MOV_RDI_RAX[0]; *(m++) = MOV_RDI_RAX[1];
				*(m++) = REX_B; *(m++) = CALL_R12[0]; *(m++) = CALL_R12[1];
				break;
			case 0b01:
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = REX_W; *(m++) = MOV_RDI; *(const char**)m = fizz; m+=8;
				*(m++) = REX_B; *(m++) = CALL_R12[0]; *(m++) = CALL_R12[1];
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP;
				break;
			case 0b10:
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = REX_W; *(m++) = MOV_RDI; *(const char**)m = buzz; m+=8;
				*(m++) = REX_B; *(m++) = CALL_R12[0]; *(m++) = CALL_R12[1];
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP;
				break;
			case 0b11:
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = REX_W; *(m++) = MOV_RDI; *(const char**)m = fizzbuzz; m+=8;
				*(m++) = REX_B; *(m++) = CALL_R12[0]; *(m++) = CALL_R12[1];
				*(m++) = NOP; *(m++) = NOP; *(m++) = NOP;
				*(m++) = NOP; *(m++) = NOP;
				break;
			default: abort();
		}
	}
	*(m++) = POP_R12[0]; *(m++) = POP_R12[1];
	*(m++) = RET;

	if (mprotect((void*)page, pagesize * num_pages, PROT_READ|PROT_EXEC) != 0) {
		perror("mprotect");
		exit(EXIT_FAILURE);
	}

	void (*pf)(void) = (void(*)(void))page;
	pf();

	return 0;
}
