#!/bin/bash
# Run checkpatch --strict on commits since HEAD~N
# Usage: ./checkpatch-series.sh <num_commits>

COMMITS=${1:?Usage: $0 <num_commits>}

for i in $(git log --oneline HEAD~"${COMMITS}"..HEAD | cut -f1 -d' '); do
    echo "$i"
    ./scripts/checkpatch.pl --strict -g "$i"
    echo "=============================================="
done
