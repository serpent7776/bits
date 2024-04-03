{fb=0}
$0 % 3 == 0 {fb = 1; printf "fizz"}
$0 % 5 == 0 {fb = 1; printf "buzz"}
fb == 0 {printf "%d", $0}
{print ""}
