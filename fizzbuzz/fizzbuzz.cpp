#include <valarray>
#include <numeric>
#include <iostream>

int main()
{
	const size_t count = 100;
	std::valarray<int> n(count);
	std::iota(std::begin(n), std::end(n), 1);
	std::valarray<bool> fs = n % 3 == 0;
	std::valarray<bool> bs = n % 5 == 0;
	std::valarray<bool> ns = !fs && ! bs;
	for (size_t i = 0; i < count; i++) {
		if (ns[i]) std::cout << n[i];
		if (fs[i]) std::cout << "fizz";
		if (bs[i]) std::cout << "buzz";
		std::cout << "\n";
	}
	return 0;
}
