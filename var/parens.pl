use warnings;
use strict;

sub p {
	my $s = shift;
	while ($s =~ s/\(\)// || $s =~ s/\[\]// || $s =~ s/{}//) {};
	return !!($s eq '');
}

use Test::More;

ok(p("()[]{}"));
ok(p("{[()]}"));
ok(p("{[({})]}"));
ok(not p("([)]"));
ok(not p("[(])"));
ok(not p("((()"));
ok(not p("{["));

ok(not p("({()}"));
ok(not p("{(((((((((())))))))))]"));

done_testing()
