.PHONY: tree
tree:
	perl tree.pl > t.awk
	diff --color=always -u t.awk tree.awk
	awk -f t.awk
