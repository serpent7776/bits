/ 1 Given an array x and a 'mask' array y consisting of zeroes and ones only, get the elements in x that are at the same positions as the ones in y. f[2 7 89 92 -123;0 1 0 1 1] -> 7 92 -123.
{x@&y}[2 7 89 92 -123;0 1 0 1 1]

/ 2 Create a dictionary from an array where the keys are the types of the elements in the array, and the values are the elements of the array.
{(@'x)!x}[(1, "c", `x)]

/ 3 Create a function with two arguments x and y, which takes the sum of x[y] without nulls.
{+/0^x@&y}[2 7 89 92 0N;0 1 0 1 1]
