#include "tuple.hpp"

#include <string>
#include <vector>

int main()
{
	{
		tuple<int> t(12);
		static_assert(std::is_same_v<int&, decltype(get<int>(t))>);
	}
	{
		tuple<int, std::vector<int>> t(12, {1,2,3});
		static_assert(std::is_same_v<int&, decltype(get<int>(t))>);
		static_assert(std::is_same_v<std::vector<int>&, decltype(get<std::vector<int>>(t))>);
	}
	{
		tuple<int, std::string> t(12, "foobar");
		static_assert(std::is_same_v<int&, decltype(get<int>(t))>);
		static_assert(std::is_same_v<std::string&, decltype(get<std::string>(t))>);
	}
	return 0;
}
