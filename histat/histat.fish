function histat
	set --local limit $argv[1]
	if test "$limit" = ""
		set limit 10
	end
	history  | awk '{print $1}' | sort | uniq -c  | sort -nr | awk -e '{sum+=$1; uniq++}' -e "NR<=$limit{print}" -e 'END{print("Total commands: ", sum); print("Unique commands:", uniq)}'
end
