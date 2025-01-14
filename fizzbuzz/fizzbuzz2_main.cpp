// verilator -Wall --cc --exe --build -j 0 sim_main.cpp fizzbuzz.v

#include "Vfizzbuzz2.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);

	Vfizzbuzz2 top {};

	top.clk = 0;
	top.reset = 0;
	top.eval();
	top.clk = 1;
	top.reset = 1;
	top.eval();
	top.reset = 0;

	for (int i = 0; i < 200; i++) {
		top.clk = !top.clk;
		top.eval();

		if (top.clk) {
			if (top.fizz) std::cout << "fizz";
			if (top.buzz) std::cout << "buzz";
			if (top.num)
				std::cout << (int)top.number;
			std::cout << "\n";
		}
	}

	return 0;
}
