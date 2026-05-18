#!/bin/bash
# Run smatch, sparse, and coccinelle on C files changed in the series
# Usage: ./check-series.sh [num_commits]  (default: 6)

COMMITS=${1:-6}
MAKE_ARGS=(W=1 ARCH=riscv LLVM=1 -j"$(nproc)")

mapfile -t CHANGED < <(git diff "HEAD~${COMMITS}..HEAD" --name-only -- '*.c')

if (( ${#CHANGED[@]} == 0 )); then
    echo "No C files changed in last ${COMMITS} commits."
    exit 0
fi

echo "=== Files to check ==="
printf '%s\n' "${CHANGED[@]}"
echo

mapfile -t OBJ_TARGETS < <(printf '%s\n' "${CHANGED[@]}" | sed 's/\.c$/.o/')

run_checker() {
    local name=$1 check=$2
    echo "=== $name ==="
    make C=1 CHECK="$check" "${MAKE_ARGS[@]}" "${OBJ_TARGETS[@]}" 2>&1 | tee "${name}.log"
    echo
}

run_checker smatch "${HOME}/bin/smatch --project=kernel"
run_checker sparse "${HOME}/bin/sparse"

echo "=== coccinelle ==="
LOGS="smatch.log sparse.log"
if ! command -v spatch &>/dev/null; then
    echo "spatch not found — skipping (install with: sudo apt install coccinelle)"
else
    mapfile -t DIRS < <(printf '%s\n' "${CHANGED[@]}" | sed 's|/[^/]*$||' | sort -u)
    for dir in "${DIRS[@]}"; do
        echo "--- $dir ---"
        make coccicheck MODE=report "${MAKE_ARGS[@]}" M="$dir" 2>&1
    done | tee cocci.log
    LOGS="$LOGS cocci.log"
fi
echo
echo "=== Done. Logs: $LOGS ==="
