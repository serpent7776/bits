infix |>
fun x |> f = f x

fun distinctBy s [] = []
  | distinctBy s (x::xs) = x :: (List.filter (fn e => s e <> s x) xs)

(* fun groupBy s [] = [] *)
  (* | groupBy s (x::xs) = xs *)

fun groupBy (keyFunc : ''a -> ''b) (lst : ''a list) : (''b * ''a list) list =
let
  fun insert (key, value) [] = [(key, [value])]
    | insert (key, value) ((k, v) :: dict) =
    if key = k then
      (k, value :: v) :: dict
    else
      (k, v) :: insert (key, value) dict
in
  List.foldl (fn (x, acc) =>
  let
    val key = keyFunc x
  in
    insert (key, x) acc
  end
) [] lst
end

fun merge cmp ([], ys) = ys
 | merge cmp (xs, []) = xs
 | merge cmp (xs as x::xs', ys as y::ys') =
      case cmp (x, y) of
           GREATER => y :: merge cmp (xs, ys')
         | _       => x :: merge cmp (xs', ys)

fun sortBy cmp [] = []
 | sortBy cmp [x] = [x]
 | sortBy cmp xs =
    let
      val ys = List.take (xs, length xs div 2)
      val zs = List.drop (xs, length xs div 2)
    in
      merge cmp (sortBy cmp ys, sortBy cmp zs)
    end

type person = {name: string, age: int}

val people = [{name="Joe", age=20}, {name="Will", age=30}, {name="Joe", age=25}]

val after = people
  |> (distinctBy #name)
  |> (groupBy #age)
  |> (List.map #2)
  |> (List.map (#name o hd))
  |> (sortBy String.compare)
