% fb(Number, Mod3, Mod5, Result)
fb(_, 0, 0, R) :- R = "fizzbuzz".
fb(_, 0, _, R) :- R = "fizz".
fb(_, _, 0, R) :- R = "buzz".
fb(N, _, _, R) :- number_chars(N, R).

fb_print(N, R) :-
	Mod3 is N mod 3,
	Mod5 is N mod 5,
	fb(N, Mod3, Mod5, R),
	format("~s~n", [R]).

fizzbuzz(First, Last) :-
	forall(between(First, Last, N), fb_print(N, _)).

main :-
	fizzbuzz(1, 100).

:- initialization(main).
