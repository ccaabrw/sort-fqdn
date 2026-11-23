#!/usr/bin/env bash
#
# sort-fqdn.sh - Sort a list of FQDNs into TLD order.
#
# Names are compared label by label from right to left (TLD first, then the
# domain, then each sub-domain), case-insensitively and ignoring any trailing
# dot. Each name is output exactly as it was given.
#
# Usage: sort-fqdn.sh [FILE...]
#   Reads one FQDN per line from the given files, or from standard input if
#   no files are given (or a file is "-"). Blank lines are ignored.

set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    sed -n '9,11s/^# \{0,1\}//p' "$0"
    exit 0
fi

# Build a sort key of the reversed labels joined with \001 (which sorts before
# any printable character, so "a.com" < "x.a.com" < "a-b.com"), sort on it,
# then strip the key again.
awk '
{
    sub(/\r$/, "")
    name = $0
    gsub(/^[ \t]+|[ \t]+$/, "", name)
    if (name == "") next
    key = tolower(name)
    sub(/\.+$/, "", key)
    n = split(key, labels, ".")
    rev = labels[n]
    for (i = n - 1; i >= 1; i--) rev = rev "\001" labels[i]
    print rev "\t" name
}
' "$@" | LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2 | cut -f2-
