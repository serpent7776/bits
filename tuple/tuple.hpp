#include <stddef.h>
#include <utility>
#include <numeric>
#include <array>
#include <new>

template <typename... Ts>
struct tuple
{
	tuple(Ts&&... ts)
	{
		init(std::index_sequence_for<Ts...>(), std::forward<Ts>(ts)...);
	}

	template <size_t... Is>
	void init(std::index_sequence<Is...>, Ts&&... ts)
	{
		constexpr const size_t N = sizeof...(Ts);
		constexpr const size_t sizes[N] = {sizeof(Ts)...};
		size_t offsets[N];
		std::exclusive_scan(sizes, sizes+N, offsets, 0);
		([buf=this->buf, offsets](Ts&& ts, size_t idx){
			const size_t offset = offsets[idx];
			void* ptr = buf + offset;
			Ts* xptr = static_cast<Ts*>(ptr);
			new (xptr) Ts;
			*xptr = std::forward<Ts>(ts);
		}(std::forward<Ts>(ts), Is), ...);
	}

	char buf[(sizeof(Ts) + ...)];
};

template <typename T, typename... Ts>
const T& get(const tuple<Ts...>& t)
{
	return {};
}
