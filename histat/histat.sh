histat() {
	local limit=${1:-10}
	history  | awk '{print $2}' | sort | uniq -c  | sort -nr | awk -e '{sum+=$1; uniq++}' -e "NR<=$limit{print}" -e 'END{print("Total commands: ", sum); print("Unique commands:", uniq)}'
}
