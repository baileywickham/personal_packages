OPTIND=1

output_file=""
verbose=0

while getopts "hi:" opt; do
	case "$opt" in
		h)
			echo "input script for watchfiles"
			exit 0
			;;
		i)
			echo "input watchfile"
			read f
			export WATCHFILE=$f
			;;
	esac
done
[ "${1:-}" = "--" ] && shift

