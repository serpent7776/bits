BEGIN {
	if (length(f) == 0 || length(g) == 0) {
		print "f and g variables should be set to filenames to compare";
		exit 1;
	}
	# report lines that are of equal length in f and g
	if (op == "=" || op == "==") {
		while((getline a < f > 0) && (getline b < g > 0)) {
			if (length(b) == length(a)) {
				print("-", a);
				print("+", b);
			}
		}
	}
	# report lines in g that are shorter than in f
	else if (op == "<") {
		while((getline a < f > 0) && (getline b < g > 0)) {
			if (length(b) < length(a)) {
				print("-", a);
				print("+", b);
			}
		}
	}
	# report lines in g that are shorter or equal to lines in f
	else if (op == "<=") {
		while((getline a < f > 0) && (getline b < g > 0)) {
			if (length(b) <= length(a)) {
				print("-", a);
				print("+", b);
			}
		}
	}
	# report lines in g that are longer than in f
	else if (op == ">") {
		while((getline a < f > 0) && (getline b < g > 0)) {
			if (length(b) > length(a)) {
				print("-", a);
				print("+", b);
			}
		}
	}
	# report lines in g that are longer or equal to lines in f
	else if (op == ">=") {
		while((getline a < f > 0) && (getline b < g > 0)) {
			if (length(b) >= length(a)) {
				print("-", a);
				print("+", b);
			}
		}
	}
	else {
		print "Unsupported operation", op, "supported operations are: < > = <= >=";
		exit 2;
	}
}
