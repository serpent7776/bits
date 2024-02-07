#include <iostream>
#include <array>
#include <utility>

template <char c>
constexpr size_t int_from_char()
{
	static_assert(c >= '0' && c <= '9', "Only digits allowed");
	return c - '0';
}

constexpr size_t pow10(size_t power)
{
	size_t result = 1;
	for (size_t i = 0; i < power; ++i) {
		result *= 10;
	}
	return result;
}

template <typename T, T... ints>
constexpr auto reverse_integer_sequence(std::integer_sequence<T, ints...>)
{
	constexpr size_t Size = sizeof...(ints);
	return std::integer_sequence<T, (Size - ints - 1)...>();
}

template <char... chars>
constexpr size_t int_from_chars()
{
	return []<size_t... Idx>(std::index_sequence<Idx...>){
		return ((int_from_char<chars>() * pow10(Idx)) + ...);
	}(reverse_integer_sequence(std::make_index_sequence<sizeof...(chars)>{}));
}

struct Ord
{
	size_t value;

	void operator-() = delete;

	operator size_t()
	{
		return value;
	}
};

template<char... chars>
constexpr Ord operator "" _th() {
	constexpr size_t n = int_from_chars<chars...>();
	static_assert(n != 0, "Ordinal must not be 0");
	return Ord{n - 1};
}

template<char... chars>
constexpr Ord operator "" _st() {
	constexpr size_t n = int_from_chars<chars...>();
	static_assert(n == 1, "First ordinal must be 1");
	return Ord{n - 1};
}

template<char... chars>
constexpr Ord operator "" _nd() {
	constexpr size_t n = int_from_chars<chars...>();
	static_assert(n == 2, "Second ordinal must be 2");
	return Ord{n - 1};
}

template<char... chars>
constexpr Ord operator "" _rd() {
	constexpr size_t n = int_from_chars<chars...>();
	static_assert(n == 3, "Third ordinal must be 3");
	return Ord{n - 1};
}

int main()
{
	std::array arr = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
	// std::cout << arr[-5_th] << '\n'; // doesn't compile
	// std::cout << arr[0_th] << '\n'; // doesn't compile
	std::cout << arr[1_st] << '\n';
	std::cout << arr[2_nd] << '\n';
	std::cout << arr[3_rd] << '\n';
	// std::cout << arr[3_nd] << '\n'; // doesn't compile
	// std::cout << arr[4_rd] << '\n'; // doesn't compile
	std::cout << arr[4_th] << '\n';
	std::cout << arr[10_th] << '\n';
	return 0;
}
