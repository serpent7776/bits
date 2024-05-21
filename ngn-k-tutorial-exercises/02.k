/ 1 Convert 23 34 45 56 to (,45; ,56) using a single primitive.
2 1 # 2_23 34 45 56
+1 _ 0 2 _ 23 34 45 56
0 1 _ 2 _ 23 34 45 56
2 3 _ 23 34 45 56

/ 2 Take the first five elements of !9, multiply them by 2, and put them back in the same place in !9.
(2 * 5 # !9),(5+!4)
,/2 1 * 0 5 _ !9

/ 3 Create the array (6 8 10; 12 14 16) using the primitives from this chapter. Try to find more than one way to do it.
((6+2*!3);(12+2*!3))
2 3 # (6+2*!3),(12+2*!3)
2 3 # 6+2*!6
0 3 _ 6+2*!6
