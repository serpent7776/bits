arg <- (commandArgs(trailingOnly = TRUE)[1] |> strsplit(''))[[1]]
print(all(arg == rev(arg)))

