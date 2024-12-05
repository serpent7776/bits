library(dplyr)
library(readr)
library(ggplot2)

data_text <- readLines(file("stdin"))
data_text <- gsub(":", "|", data_text)
data_string <- paste(data_text, collapse = "\n")

data <- read_delim(
  data_string,
  skip = 1,
  delim = "|",
  col_names = c("import_time", "self_time", "cumulative", "package"),
  col_types = "cnnc",
  show_col_types = FALSE,
  trim_ws = TRUE
) %>%
  arrange(desc(self_time)) %>%
  slice_head(n = 50)

p <- ggplot(data, aes(x = reorder(package, self_time), y = self_time)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Python Import Times (Self Time)",
    x = "Package",
    y = "Self Time [us]"
  ) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    axis.text.y = element_text(size = 8),
    plot.title = element_text(hjust = 0.5),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank()
  )

print(p)
ggsave("import_times.png", p, width = 10, height = 8, dpi = 300)
