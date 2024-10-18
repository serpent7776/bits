constexpr bool digit(char c) { return c >= '0' && c <= '9'; }
constexpr bool dash(char c) { return c == '-'; }

template<typename... Fs>
constexpr bool validate(const char* s, Fs... fs)
{
	return  (... && (s && fs(*s++))) && (!*s);
}

constexpr bool validate_date(const char* s)
{
	return validate(s,
		digit, digit, digit, digit,
		dash,
		digit, digit,
		dash,
		digit, digit);
}

int main()
{
	static_assert(not validate_date(""));
	static_assert(validate_date("2024-01-01"));
	static_assert(not validate_date("2024_01_01"));
	static_assert(not validate_date("20240101"));
	static_assert(not validate_date("2024-01-01-01"));
}
