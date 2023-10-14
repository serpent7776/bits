#!/usr/bin/env -S swipl -c
?- length(S, 8), maplist(=("☀"), S), atomic_list_concat(S, ", ", A), atom_string(A, X), writef("[ %w ]", [X]).
