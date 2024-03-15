#!/usr/bin/env Rscript

library(png)
library(Cairo)

mainfont <- "New Century Schoolbook"

CairoFonts(
  regular = paste(mainfont, "style=Regular", sep = ":"),
  bold = paste(mainfont, "style=Bold", sep = ":"),
  italic = paste(mainfont, "style=Italic", sep = ":"),
  bolditalic = paste(mainfont, "style=Bold Italic,BoldItalic", sep = ":")
)

CairoPNG(file = "output.png", width = 64, height = 64)
par(mar = c(0, 0, 0, 0))
plot.new()
text(.5, .5, "π", cex = 8, col = rgb(0, 0, 0, 1), font = 3)
dev.off()

pi <- readPNG("output.png")
means <- apply(pi, c(1, 2), mean)
chars <- apply(means, 1:2, function(px) ifelse(px > 0.21, " ", "π"))
rows <- apply(chars, 1, function(row) paste(row, collapse=""))
cat(paste(rows, collapse="\n"), "\n")
