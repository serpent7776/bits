#include "tuple.hpp"

#include <string>
#include <vector>

int main()
{
	tuple<int> i(12);
	tuple<int, std::vector<int>> iv(12, {1,2,3});
	tuple<int, std::string> is(12, "foobar");
	return 0;
}
