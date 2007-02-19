#!/bin/bash
find make sgml -type f | grep -vF .svn | grep -vP '~$' | grep -vP '\.swp$' |
(while read T; do
    dir="$HOME/apps/docbook-builder/share/$(dirname "$T")"
    mkdir -p "$dir"
    cp -f "$T" "$dir"
done)
