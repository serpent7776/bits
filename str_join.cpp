#include "catch.hpp"

#include <iostream>
#include <string>
#include <string_view>

template<typename Sep, typename String, typename ...Strings>
std::string str_join(Sep&& sep, String&& string, Strings&&... strings)
{
	std::string buf = string;
	(([&buf, sep](auto&& str){
		if (!buf.empty() && !std::string_view(str).empty())
		{
			buf += sep;
		}
		buf += str;
	}(std::forward<Strings>(strings))), ...);
	return buf;
}

TEST_CASE("tests")
{
	REQUIRE(str_join('x', "test") == "test");
	REQUIRE(str_join(' ', "hello", "world") == "hello world");
	REQUIRE(str_join('-', "foo", "bar", "baz") == "foo-bar-baz");
	REQUIRE(str_join('*', "a", "b", "c", "d") == "a*b*c*d");
	REQUIRE(str_join(';', "", "", "", "x", "y") == "x;y");
	REQUIRE(str_join(';', "x", "", "", "x") == "x;x");
}
