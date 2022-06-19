all: dbdump


dbdump:
	set -o pipefail; node dbdump.mjs 2>&1 | less -S
