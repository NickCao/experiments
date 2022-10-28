#!/usr/bin/env bash
for path in $(nix path-info -r /run/current-system); do
  find $path -type f -executable -exec objdump --no-addresses --no-show-raw-insn -d '{}' \; | awk '{ print $1; }' | grep -oE "^[a-z]+"
done | sort | uniq -c > result
