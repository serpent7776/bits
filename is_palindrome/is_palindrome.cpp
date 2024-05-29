#include <algorithm>
#include <string_view>
#include <ranges>

bool is_palindrome(std::string_view c)
{
	return std::ranges::equal(c, std::ranges::reverse_view(c));
}

int main(int argc, char *argv[])
{
	return !is_palindrome(argv[1]);
}
