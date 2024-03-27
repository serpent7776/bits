#include <valarray>
#include <numeric>
#include <iostream>

int main()
{
	const size_t count = 100;
	std::valarray<int> z(0, count);
	std::valarray<int> f(3, count);
	std::valarray<int> b(5, count);
	std::valarray<int> n(count);
	std::iota(std::begin(n), std::end(n), 1);
	std::valarray<bool> fs = n % f == z;
	std::valarray<bool> bs = n % b == z;
	std::valarray<bool> ns = !fs && ! bs;
	for (size_t i = 0; i < count; i++) {
		if (ns[i]) std::cout << n[i];
		if (fs[i]) std::cout << "fizz";
		if (bs[i]) std::cout << "buzz";
		std::cout << "\n";
	}
	return 0;
}
