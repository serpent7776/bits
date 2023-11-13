let fizzbuzz n =
        match (n mod 3, n mod 5) with
        | (0, 0) -> "fizzbuzz"
        | (0, _) -> "fizz"
        | (_, 0) -> "buzz"
        | (_, _) -> string_of_int n

let () = for n = 1 to 100 do
        Printf.printf "%s\n" (fizzbuzz n)
done
