#!/bin/sh
# Fail if the plugin contains setup-specific literals: version numbers, personal paths
# or host names, or credentials. Run from the repository root (CI and pre-commit).
# Intentional exceptions live in references/compat.md only.

cd "$(dirname "$0")/.." || exit 2
status=0

check() { # description, extended-regex
    hits=$(grep -rnIE "$2" skills scripts/sfos-probe.sh README.md .claude-plugin 2>/dev/null \\
           | grep -v 'references/compat.md' | grep -v '/home/defaultuser')
    if [ -n "$hits" ]; then
        printf 'LINT: %s\n%s\n\n' "$1" "$hits"
        status=1
    fi
}

check "SDK/OS version literal"        '(^|[^0-9.])[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+([^0-9]|$)'
# ~/SailfishOS alone is the documented default location (probe search list); paths
# below it and absolute user homes are not allowed (/home/defaultuser is the
# standard on-device user and is exempt).
check "hardcoded SDK path"            '~/SailfishOS/|/home/[a-z]|/Users/'
# Personal names (your username, VM and host names) belong in an untracked local file,
# one extended-regex alternative per line: .lint-denylist (or $LINT_DENYLIST).
deny="${LINT_DENYLIST:-.lint-denylist}"
if [ -s "$deny" ]; then
    check "personal host or user name" "$(paste -sd'|' "$deny")"
fi
check "credential-looking string"     '(password|passwd)[[:space:]]*[=:][[:space:]]*[^[:space:]<]'
check "hardcoded emulator port"       '(^|[^0-9])2223([^0-9]|$)'

[ "$status" -eq 0 ] && echo "lint-generic: clean"
exit "$status"
