#!/bin/sh

ls $* | xargs -n 2 | while read f; do
	zcmp -s $f
	if [ "$?" != 0 ]; then
		echo "$f differ"
		vim -d $f
	fi
done
