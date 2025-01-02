generate_snowflake <- function(size = 64, iterations = 30) {
  grid <- matrix(0, nrow = size, ncol = size)
  center <- size / 2
  grid[center, center] <- 1
  grid[center + 1, center - 0] <- 1
  grid[center - 1, center + 0] <- 1
  grid[center + 0, center - 1] <- 1
  grid[center + 0, center + 1] <- 1

  for (i in 1:iterations) {
    new_grid <- grid
    for (x in 1:size) {
      for (y in 1:size) {
        neighbors <- sum(grid[max(1, x - 1):min(size, x + 1), max(1, y - 1):min(size, y + 1)])
        if (neighbors %in% c(1, 7)) {
          new_grid[x, y] <- 1
        }
      }
    }
    grid <- new_grid
    print_snowflake(grid)
  }
  return(grid)
}

print_snowflake <- function(grid) {
  cat(c("\033[2J", "\033[0;0H"))
  for (i in 1:nrow(grid)) {
    for (j in 1:ncol(grid)) {
      cat(ifelse(grid[i, j] == 1, "*", " "))
    }
    cat("\n")
  }
  Sys.sleep(0.1)
}

cat("\033[?25l")

size <- 64
iterations <- 30
snowflake <- generate_snowflake(size, iterations)
print_snowflake(snowflake)

cat("\033[?25h")
