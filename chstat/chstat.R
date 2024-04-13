library(ggplot2)

az <- 65:90
AZ <- 97:122
azAZ <- c(az, AZ)

lines <- readLines(file("stdin"))

text <- paste(lines, collapse = "")
nums <- charToRaw(text) |> as.integer()

has_lo <- any(nums %in% az)
has_up <- any(nums %in% AZ)

xs <- c()
if (has_lo) {
  xs <- c(xs, az)
}
if (has_up) {
  xs <- c(xs, AZ)
}
xs <- unlist(strsplit(intToUtf8(xs), ""))

characters <- unlist(strsplit(text, ""))[nums %in% azAZ]
char_counts <- table(characters)

all_letters <- data.frame(Character = xs, Count = 0)
ascii_df <- data.frame(Character = names(char_counts), Count = as.numeric(char_counts))
agg <- aggregate(. ~ Character, rbind(ascii_df, all_letters), sum)
agg$Character <- factor(agg$Character, levels = xs)

ggplot(agg, aes(x = Character, y = Count)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  theme_minimal() +
  labs(title = "Histogram of ASCII Characters", x = "ASCII Characters", y = "Count")
