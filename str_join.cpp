#define CATCH_CONFIG_ENABLE_BENCHMARKING
#include "catch.hpp"

#include <string>
#include <string_view>

std::string str_join_v([[ maybe_unused ]]std::string_view sep, auto... strings)
{
	std::string buf;
	([&](std::string_view str){
		if (!str.empty())
		{
			(buf += str) += sep;
		}
	}(strings), ...);
	if (!buf.empty())
	{
		buf.pop_back();
	}
	return buf;
}
std::string str_join(std::string_view sep, const auto&... strings)
{
	return str_join_v(sep, std::string_view(strings)...);
}
std::string str_join(char sep, const auto&... strings)
{
	std::string_view sep_view(&sep, 1);
	return str_join_v(sep_view, std::string_view(strings)...);
}

const char* string_literal(const char* s)
{
	return s;
}

std::string string(const char* s)
{
	return s;
}

std::string_view string_view(const char* s)
{
	return s;
}

TEST_CASE("string literal tests")
{
	auto f = string_literal;
	CHECK(str_join('x', f("test"), "") == "test");
	CHECK(str_join(' ', f("hello"), f("world")) == "hello world");
	CHECK(str_join('-', f("foo"), f("bar"), f("baz")) == "foo-bar-baz");
	CHECK(str_join('*', f("a"), f("b"), f("c"), f("d")) == "a*b*c*d");
	CHECK(str_join(';', f(""), f(""), f(""), f("x"), f("y")) == "x;y");
	CHECK(str_join(';', f("x"), f(""), f(""), f("x")) == "x;x");
	CHECK(str_join(';', f("")) == "");
}

TEST_CASE("string tests")
{
	auto f = string;
	CHECK(str_join('x', f("test")) == "test");
	CHECK(str_join(' ', f("hello"), f("world")) == "hello world");
	CHECK(str_join('-', f("foo"), f("bar"), f("baz")) == "foo-bar-baz");
	CHECK(str_join('*', f("a"), f("b"), f("c"), f("d")) == "a*b*c*d");
	CHECK(str_join(';', f(""), f(""), f(""), f("x"), f("y")) == "x;y");
	CHECK(str_join(';', f("x"), f(""), f(""), f("x")) == "x;x");
	CHECK(str_join(';', f("")) == "");
}

TEST_CASE("string view tests")
{
	auto f = string_view;
	CHECK(str_join('x', ("test")) == "test");
	CHECK(str_join(' ', f("hello"), f("world")) == "hello world");
	CHECK(str_join('-', f("foo"), f("bar"), f("baz")) == "foo-bar-baz");
	CHECK(str_join('*', f("a"), f("b"), f("c"), f("d")) == "a*b*c*d");
	CHECK(str_join(';', f(""), f(""), f(""), f("x"), f("y")) == "x;y");
	CHECK(str_join(';', f("x"), f(""), f(""), f("x")) == "x;x");
	CHECK(str_join(';', f("")) == "");
}

TEST_CASE("benchmark")
{
	std::string s;
	BENCHMARK("str_join 1")
	{
		s = str_join(".", "a");
	};
	BENCHMARK("str_join 2")
	{
		s = str_join(".", "a", "b");
	};
	BENCHMARK("str_join 3")
	{
		s = str_join(".", "a", "b", "c");
	};
	BENCHMARK("str_join 4")
	{
		s = str_join(".", "a", "b", "c", "d");
	};
}
