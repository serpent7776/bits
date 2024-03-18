#!/usr/bin/env Rscript
df <- data.frame(number = 1:100, result = as.character(1:100))
df$result[df$number %% 3 == 0] <- "fizz"
df$result[df$number %% 5 == 0] <- "buzz"
df$result[df$number %% 15 == 0] <- "fizzbuzz"
cat(paste(df$result, collapse="\n"), sep="\n")
