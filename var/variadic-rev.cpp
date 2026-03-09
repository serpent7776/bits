#include <type_traits>

template<typename ...Ts>
struct types;

template<typename ...Ts>
struct unpack
{
	using type = types<Ts...>;
};

template<typename ...Ps, typename ...Ts>
struct unpack<types<Ps...>, Ts...>
{
	using type = types<Ps..., Ts...>;
};

template<typename H, typename ...Tail>
struct rev
{
	using rest = typename rev<Tail...>::type;
	using type = typename unpack<rest, H>::type;
};

template<typename T>
struct rev<T>
{
	using type = types<T>;
};

struct Point
{
	int x;
	int y;
};

int main()
{
	static_assert(std::is_same_v<rev<int, bool, Point>::type, types<Point, bool, int>>);
	static_assert(std::is_same_v<rev<int, bool, char>::type, types<char, bool, int>>);
	static_assert(std::is_same_v<rev<int, int>::type, types<int, int>>);
	static_assert(std::is_same_v<rev<int>::type, types<int>>);
}
