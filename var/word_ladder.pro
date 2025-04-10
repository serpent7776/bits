:- module(word_ladder, [find_word_ladder/4]).
:- use_module(library(plunit)).

one_char_diff(String1, String2) :-
	atom_chars(String1, Chars1),
	atom_chars(String2, Chars2),
	dist(Chars1, Chars2, 0, N),
	N = 1.

dist([], [], C, R) :- C = R.
dist([H1|T1], [H2|T2], Count, R) :-
	(H1 \= H2 -> NewCount is Count + 1 ; NewCount is Count),
	dist(T1, T2, NewCount, R).

construct_path([H|T], End, _, Path) :-
	H = End,
	reverse([H|T], Path).
construct_path([H|T], End, G, Path) :-
	member((H, Next), G),
	\+ member(Next, T),
	construct_path([Next, H|T], End, G, Path).

cmp_length(A, B) :-
	length(A, La),
	length(B, Lb),
	La =< Lb.

find_word_ladder(Start, End, Dictionary, Result) :-
	findall((Word1, Word2),
		(member(Word1, Dictionary), member(Word2, Dictionary), one_char_diff(Word1, Word2)),
		G),
	findall(Path, construct_path([Start], End, G, Path), Paths),
	min_member(cmp_length, Result, Paths).

:- begin_tests(word_ladder).

% Test Case 1: Basic ladder
test(short_ladder) :-
	Start = "hit",
	End = "cog",
	Dictionary = ["hit", "hot", "dot", "dog", "cog"],
	assertion(find_word_ladder(Start, End, Dictionary, Result)),
	assertion(Result = ["hit", "hot", "dot", "dog", "cog"]).

% Test Case 2: No ladder possible
test(no_ladder) :-
	Start = "cat",
	End = "zip",
	Dictionary = ["cat", "cot", "cog"],
	assertion(\+ find_word_ladder(Start, End, Dictionary, _)).

% Test Case 3: Start and end are the same
test(same_word) :-
	Start = "cat",
	End = "cat",
	Dictionary = ["cat", "cot", "cog"],
	assertion(find_word_ladder(Start, End, Dictionary, Result)),
	assertion(Result = ["cat"]).

% Test Case 4: Longer ladder with multiple paths
test(longer_ladder) :-
	Start = "lead",
	End = "gold",
	Dictionary = ["lead", "load", "goad", "gold", "lewd"],
	assertion(find_word_ladder(Start, End, Dictionary, Result)),
	assertion(Result = ["lead", "load", "goad", "gold"]).

% Test Case 4b: Longer ladder with multiple paths
test(longer_ladder) :-
	Start = "lead",
	End = "gold",
	Dictionary = ["lead", "lewd", "lewa", "lowa", "lowd", "lold", "gold", "load", "goad", "gold"],
	assertion(find_word_ladder(Start, End, Dictionary, Result)),
	assertion(Result = ["lead", "load", "lold", "gold"]).

:- end_tests(word_ladder).
