#!/usr/bin/env Rscript
c <- 1:100
c[seq(0, 100, 3)] <- "fizz"
c[seq(0, 100, 5)] <- "buzz"
c[seq(0, 100, 15)] <- "fizzbuzz"
cat(c, sep = "\n")
