CXXFLAGS=-std=c++20 -O2 -Wall -Wextra -pedantic

all: th run

th: th.o
	${CXX} ${CXXFLAGS} -o $@ $<

.PHONY: run
run:
	./th
