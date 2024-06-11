#include <iostream>
#include <type_traits>
#include <utility>

template<typename... Ts>
std::common_type_t<Ts...> coalesce(Ts&&... ts) {
	auto result = std::common_type_t<Ts...>();
	(void)(((bool)ts ? ((bool)(result = std::forward<Ts>(ts))) : false) || ...);
	return result;
}

int main()
{
	std::cout << coalesce(0, 1, 2, 3) << '\n';
	std::cout << coalesce(1, 2, 3) << '\n';
	std::cout << coalesce(2, 3) << '\n';
	std::cout << coalesce(0, 3) << '\n';
	std::cout << coalesce(0, 0, 0, 0, -1) << '\n';
	std::cout << coalesce(0, 0, 0, 0, 0) << '\n';
}
