CXXFLAGS=-Wall -Wextra -pedantic -O2 -std=c++20 -msse4.1 -mavx2
LDFLAGS=-lCatch2Main -lCatch2

all: popcnt

popcnt: popcnt.o
	g++ -o popcnt popcnt.o -lCatch2Main -lCatch2

test: popcnt
	./popcnt
