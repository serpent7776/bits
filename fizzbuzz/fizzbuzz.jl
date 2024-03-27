#!/usr/bin/env julia

println(join((n -> join([n, "fizz", "buzz"][[n%3>0 && n%5>0, n%3==0, n%5==0]])).(1:100), "\n"))
