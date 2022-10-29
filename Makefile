CXXFLAGS=-std=c++20 -Wall -Wextra -pedantic -O2

test: str_join
	./str_join

str_join: main.o str_join.o
	g++ -o str_join  main.o str_join.o
