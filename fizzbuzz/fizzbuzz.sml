fun fizzbuzz n =
        case (n mod 3, n mod 5) of
          (0, 0) => "fizzbuzz"
        | (0, _) => "fizz"
        | (_, 0) => "buzz"
        | (_, _) => Int.toString n

fun loop (n, max) =
  if n = max then ()
  else (print (fizzbuzz n); print "\n"; loop (n+1, max))

val () = loop (1, 100)
