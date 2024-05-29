/ Write a function to convert seconds into hours, minutes and seconds, using \.
{24 60 60\x}10000

/ Write a function that takes a list of numbers x and a number y. Group the numbers in x into a dictionary based on whether they are multiples of y. f[1 3 5 9;3] -> (0;1)!(1 5;3 9)
{{(0;1)!(x@&y;x@&~y)}[x;0<y!x]}[1 3 5 9;3]
