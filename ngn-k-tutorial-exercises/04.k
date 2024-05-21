/ 1 Get the third column of the array 4 4#!16 using a projection. Then do it without a projection.
(4 4#!16)[;2]
,/1#2_+(4 4#!16)

/ 3 Write a function to add the first two elements of an array, but do it without indexing.
{+/2#x}[!4]
{(1#x)+(1_2#x)}[4 5 6]
