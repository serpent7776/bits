#!/usr/bin/env Rscript
a <- commandArgs(trailingOnly = TRUE)
y <- as.integer(a[1])
m <- as.integer(a[2])
d <- as.integer(a[3])

M <- c( 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 )

ry <- 1970
rm <- 1
rd <- 1
rn <- 4 # Thursday

is_leap <- function(y) (y %% 4 == 0 && y %% 100 != 0) || y %% 400 == 0
leaps <- sum(sapply(1970:y, is_leap))
dd <- (d-1) + sum((M)[1:m]) + (y-ry) * 365 + leaps + (-1 * (is_leap(y) && m %in% c(1,2)))

days <- c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
print(days[1 + (dd + 7 - rn) %% 7])
