#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>
#include <utility>
#include <cassert>

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

unsigned char* push1(unsigned char* m, unsigned char n)
{
	*(unsigned char*)m = n;
	return m+sizeof(unsigned char);
}
unsigned char* push1(unsigned char* m, size_t n)
{
	*(size_t*)m = n;
	return m+sizeof(size_t);
}
unsigned char* push1(unsigned char* m, const char* s)
{
	*(const char**)m = s;
	return m+sizeof(const char*);
}
template <typename T, size_t N>
unsigned char* push1(unsigned char* m, T (&arr)[N])
{
	memcpy(m, arr, sizeof(arr));
	return m+sizeof(arr);
}
template <typename Ret, typename... Args>
unsigned char* push1(unsigned char* m, Ret(*f)(Args...))
{
	*(Ret(**)(Args...))m = f;
	return m+sizeof(f);
}

template <typename ...Xs>
unsigned char* push(unsigned char* m, Xs&&... xs)
{
	((m = push1(m, std::forward<Xs>(xs))),...);
	return m;
}

int main(int argc, char *argv[])
{
	if (argc < 2) return usage();

	const int n = atoi(argv[1]);
	if (n == 0) exit(0);
	if (n < 0) exit(1);

	const size_t bytes = 16 + 40 * n + 3;

	unsigned char* page = (unsigned char*)mmap(nullptr, bytes, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (page == MAP_FAILED) {
		perror("mmap");
		exit(EXIT_FAILURE);
	}

	unsigned char* m = page;
	m = push(m,
		NOP, NOP, NOP, NOP,
		PUSH_R12,
		REX_WB, MOV_R12, puts
	);
	for (int i = 1; i <= n; i++)
	{
		const int f = i % 3 == 0;
		const int b = i % 5 == 0;
		switch((b << 1) | f)
		{
			case 0b00:
				m = push(m,
					NOP, NOP, NOP,
					NOP, NOP, NOP,
					REX_W, MOV_RAX, itoa,
					NOP, NOP, NOP,
					NOP, NOP, NOP,
					REX_W, MOV_RDI, (size_t)i,
					CALL_RAX,
					REX_W, MOV_RDI_RAX,
					REX_B, CALL_R12
				);
				break;
			case 0b01:
				m = push(m,
					NOP, NOP, NOP,
					NOP, NOP, NOP,
					REX_W, MOV_RDI, fizz,
					REX_B, CALL_R12,
					NOP, NOP, NOP,
					NOP, NOP
				);
				break;
			case 0b10:
				m = push(m,
					NOP, NOP, NOP,
					NOP, NOP, NOP,
					REX_W, MOV_RDI, buzz,
					REX_B, CALL_R12,
					NOP, NOP, NOP,
					NOP, NOP
				);
				break;
			case 0b11:
				m = push(m,
					NOP, NOP, NOP,
					NOP, NOP, NOP,
					REX_W, MOV_RDI, fizzbuzz,
					REX_B, CALL_R12,
					NOP, NOP, NOP,
					NOP, NOP
				);
				break;
			default: abort();
		}
	}
	push(m, POP_R12, RET);

	if (mprotect((void*)page, bytes, PROT_READ|PROT_EXEC) != 0) {
		perror("mprotect");
		exit(EXIT_FAILURE);
	}

	void (*pf)(void) = (void(*)(void))page;
	pf();

	return 0;
}
