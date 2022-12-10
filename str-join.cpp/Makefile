CXXFLAGS=-std=c++20 -Wall -Wextra -pedantic -O2 -ggdb3

.PHONY: test
test: str_join
	./str_join

str_join: main.o str_join.o
	${CXX} ${CXXFLAGS} -o str_join  main.o str_join.o
