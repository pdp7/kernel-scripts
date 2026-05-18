#!/bin/bash
# build-matrix.sh - 0day-style strict build matrix for the QoS series
# Runs each configuration sequentially with -j16 (full 16-core machine).
# Logs go to build-matrix/logs/<name>.log so you can tail -f the active build.

set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
MATRIX="$ROOT/build-matrix"
# Kbuild rejects O= when the source tree has in-tree build artifacts.
# Use a linked worktree (clean checkout of HEAD) as the make source,
# but keep all build outputs in $MATRIX inside the main tree.
WORKTREE="$ROOT/.worktrees/build-matrix"

declare -A ARCH_FOR=(
    [current]="riscv"
    [rv64-defconfig]="riscv"
    [rv64-allnoconfig]="riscv"
    [rv64-randconfig]="riscv"
    [x86_64-defconfig]="x86_64"
    [arm64-defconfig]="arm64"
)

declare -A KCONFIG_TARGET=(
    [current]="olddefconfig"
    [rv64-defconfig]="defconfig"
    [rv64-allnoconfig]="allnoconfig"
    [rv64-randconfig]="randconfig"
    [x86_64-defconfig]="defconfig"
    [arm64-defconfig]="defconfig"
)

ORDER=(current x86_64-defconfig arm64-defconfig rv64-defconfig rv64-allnoconfig rv64-randconfig)

usage() {
    cat <<EOF
Usage: $0 [name|--clean|--list|-h]

  (no arg)   run all builds sequentially in this order:
               ${ORDER[*]}
  name       run only the named build (must be one of the names above)
  --clean    rm -rf build-matrix/ and exit
  --list     list build names and exit
  -h, --help show this help

Each build:
  - lives in build-matrix/<name>/ as its O= dir
  - has its .config snapshotted to build-matrix/configs/<name>.config
  - has its log streamed to build-matrix/logs/<name>.log (line-buffered, tail-able)
  - is invoked as: make ARCH=<arch> LLVM=1 W=1 -j16 -k
  - the kernel's curated -Werror= flags (implicit-function-declaration,
    return-type, incompatible-pointer-types, etc.) still fire as errors;
    blanket -Werror is intentionally NOT used, since W=2 surfaces a long
    tail of pre-existing -Wshadow/-Wunused-macros warnings that are noise
  - uses a clean linked worktree at .worktrees/build-matrix/ as srctree,
    so the main tree's in-tree build artifacts are not disturbed
EOF
}

case "${1:-}" in
    -h|--help)
        usage; exit 0;;
    --list)
        printf '%s\n' "${ORDER[@]}"; exit 0;;
    --clean)
        rm -rf "$MATRIX"
        echo "Removed $MATRIX"
        exit 0;;
esac

if [[ $# -gt 1 ]]; then
    usage; exit 1
fi

ONLY="${1:-}"
if [[ -n "$ONLY" && -z "${ARCH_FOR[$ONLY]:-}" ]]; then
    echo "Unknown build: $ONLY"
    usage; exit 1
fi

if [[ ! -f "$ROOT/.config" ]]; then
    echo "ERROR: $ROOT/.config does not exist; the 'current' build needs it" >&2
    exit 1
fi

mkdir -p "$MATRIX/configs" "$MATRIX/logs"

if [[ ! -f "$MATRIX/configs/pre-matrix.config.bak" ]]; then
    cp "$ROOT/.config" "$MATRIX/configs/pre-matrix.config.bak"
    echo "Backed up .config -> $MATRIX/configs/pre-matrix.config.bak"
fi

if [[ ! -d "$WORKTREE" ]]; then
    echo "--- creating clean worktree at $WORKTREE ---"
    mkdir -p "$(dirname "$WORKTREE")"
    git -C "$ROOT" worktree add --detach "$WORKTREE" HEAD >/dev/null
fi
SRC="$WORKTREE"
echo "Using source tree: $SRC"

generate_config() {
    local name="$1"
    local arch="${ARCH_FOR[$name]}"
    local target="${KCONFIG_TARGET[$name]}"
    local odir="$MATRIX/$name"

    mkdir -p "$odir"

    echo "--- generating config: $name (ARCH=$arch, target=$target) ---"

    if [[ "$name" == "current" ]]; then
        cp "$ROOT/.config" "$odir/.config"
        make -C "$SRC" O="$odir" ARCH="$arch" LLVM=1 olddefconfig >/dev/null
    elif [[ "$name" == "rv64-randconfig" ]]; then
        local seed=${KCONFIG_SEED:-$RANDOM$RANDOM}
        echo "$seed" > "$MATRIX/configs/rv64-randconfig.seed"
        echo "    randconfig seed: $seed"
        KCONFIG_SEED="$seed" make -C "$SRC" O="$odir" ARCH="$arch" LLVM=1 randconfig >/dev/null
    else
        make -C "$SRC" O="$odir" ARCH="$arch" LLVM=1 "$target" >/dev/null
    fi

    cp "$odir/.config" "$MATRIX/configs/$name.config"
}

build_one() {
    local name="$1"
    local arch="${ARCH_FOR[$name]}"
    local odir="$MATRIX/$name"
    local log="$MATRIX/logs/$name.log"

    echo
    echo "============================================================"
    echo "==== building $name (ARCH=$arch)"
    echo "==== log: $log"
    echo "==== started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "============================================================"

    local ts rc dur
    ts=$(date +%s)
    : > "$log"

    set +e
    make -C "$SRC" O="$odir" ARCH="$arch" LLVM=1 W=1 KCFLAGS="" -j16 -k 2>&1 \
        | tee -a "$log"
    rc=${PIPESTATUS[0]}
    set -e

    dur=$(( $(date +%s) - ts ))
    {
        echo
        echo "EXIT=$rc duration=${dur}s"
    } | tee -a "$log"
    return "$rc"
}

if [[ -n "$ONLY" ]]; then
    builds=("$ONLY")
else
    builds=("${ORDER[@]}")
fi

echo "=== Phase A: generate configs ==="
for name in "${builds[@]}"; do
    generate_config "$name"
done

echo
echo "=== Phase B: sequential builds ==="
declare -A RESULTS
overall=0
for name in "${builds[@]}"; do
    if build_one "$name"; then
        RESULTS[$name]="PASS"
    else
        RESULTS[$name]="FAIL($?)"
        overall=1
    fi
done

echo
echo "============================================================"
echo "Build matrix summary"
echo "============================================================"
for name in "${builds[@]}"; do
    printf "  %-22s  %s\n" "$name" "${RESULTS[$name]}"
done

exit "$overall"
