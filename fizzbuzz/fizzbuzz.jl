#!/usr/bin/env julia

a = map(n -> [string(n), "fizz", "buzz", "fizzbuzz"][1+((n % 3 == 0) + 2 * (n % 5 == 0))], 1:100)
println(join(a, "\n"))
