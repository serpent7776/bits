#!/bin/sh
free -m -s 1 | awk '{print $0} $2+0>0 {d=int(78*$3/$2); e=78-(d>0?d:1); s=sprintf("[%0"d"d%"e"s]\n", 1, " "); gsub("0", "=", s); gsub("1", ">", s); print s }'
