CXXFLAGS=-Wall -Wextra -pedantic -std=c++20 -Og

.PHONY: test
test: test.o
	$(CXX) -o test test.o
	./test

test.o: test.cpp swap.hpp Makefile
