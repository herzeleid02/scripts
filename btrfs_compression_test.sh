# stolen from https://gitlab.com/hartang/btrfs-compression-test


#!/usr/bin/env bash
#
# # Btrfs compression benchmark
#
# This script performs a simple compression/decompression benchmark on the
# glibc source code or an optional FILE, if specified. It compares algorithms
# supported by Btrfs transparent filesystem compression, which currently
# includes:
#
# - zlib (via pigz)
# - lzo (via lzop)
# - zstd
#
# For each algorithm, it iterates through multiple compression levels and
# prints:
#
# - Compression time in seconds
# - Compression ratio in percent, calculated as (compressed size / original size)
# - Decompression time in seconds
#
# This is not a sophisticated benchmark in that it doesn't perform repeated
# runs of each algorithm. Every algorithm is run exactly once at each of the
# specified compression levels.
#
#
# # Arguments
#
# FILE: Path to a file to compress/decompress (optional). Must be a single file
#       and not a folder.
#
#
# # Executing this benchmark
#
# This script expects to be run on a Fedora host. You can run it in a container
# like this:
#
# ```
# podman run --rm -it -v "$PWD:$PWD" -w "$PWD" --security-opt label=disable \
#     registry.fedoraproject.org/fedora:37 ./btrfs_compression_test.sh
# ```
#
# Replacing podman with docker should work, too.
set -euo pipefail

function _ok {
    echo -e "[\e[32m OK \e[0m]" "$@"
}
function _info {
    echo -e "[\e[34mINFO\e[0m]" "$@"
}
function _erro {
    echo -e "[\e[31mERRO\e[0m]" "$@" 1>&2
}
function _usage {
    echo ""
    echo "Usage: $0 [FILE]"
    echo ""
    echo "Perform a benchmark of Btrfs-compatible compression utilities."
    echo "Compression is performed on FILE if specified, GNU libc sources otherwise."
    echo ""
}

# Sanity checks
[[ "$#" -gt 1 ]] && { \
    _usage; \
    exit 1; \
}

if [[ "$#" -eq 1 ]]; then
    [[ "$1" = "--help" ]] || [[ "$1" = "-h" ]] && _usage && exit 0

    TARGET_FILE="$1"
    _info "Using file '$TARGET_FILE' as compression target"
    [[ -f "$TARGET_FILE" ]] || { \
        _erro "Requested file '$TARGET_FILE' doesn't exist or isn't accessible"; \
        exit 1; \
    }
else
    TARGET_FILE="glibc-2.36.tar"
    _info "Using file '$TARGET_FILE' as compression target"
    [[ -f "$TARGET_FILE" ]] || { \
        _info "Target file '$TARGET_FILE' not found, downloading now..."; \
        curl -LO# "http://ftp.gnu.org/gnu/glibc/glibc-2.36.tar.gz"; \
        gunzip "glibc-2.36.tar.gz"; \
        _ok "Download successful!"; \
    }
fi
TMPDIR="$(mktemp -d)"
_info "Copying '$TARGET_FILE' to '$TMPDIR/' for benchmark..."
cp "$TARGET_FILE" "$TMPDIR/"
cd "$TMPDIR"

## Constants and definitions, please don't touch
TARGET_COMPRESSED="compressed.tar"
TARGET_UNCOMPRESSED="uncompressed.tar"
FILESIZE_BEFORE="$(du -b "$TARGET_FILE" | cut -f1)"

# Test a compression algorithm.
#
# Arguments:
#     $1: maximum compression level to test
#     $2: commandline for compression
#     $3: commandline for decompression
function test_compression {
    echo ""
    echo " Level | Time (compress) | File Size Savings | Time (decompress)"
    echo "-------+-----------------+-------------------+-------------------"
    for level in $(seq 1 "$1"); do
        printf " %5d" "$level"

        # Measure compression time
        TIC="$(date +%s%N)"
        eval "$2"
        TOC="$(date +%s%N)"
        TIME_TAKEN="$(bc <<<"scale=3;($TOC - $TIC)/1000/1000/1000")"
        printf " | %14.3fs" "$TIME_TAKEN"

        # Measure compression ratio
        FILESIZE_AFTER="$(du -b "$TARGET_COMPRESSED" | cut -f1)"
	RATIO="$(bc <<<"scale=5;100*(1-$FILESIZE_AFTER/$FILESIZE_BEFORE)")"
        printf " | %16.3f%%" "$RATIO"

        # Measure decompression time
        TIC="$(date +%s%N)"
        eval "$3"
        TOC="$(date +%s%N)"
        TIME_TAKEN="$(bc <<<"scale=3;($TOC - $TIC)/1000/1000/1000")"
        printf " | %16.3fs\n" "$TIME_TAKEN"

        # Make sure the decompressed file matches the input
        # This shouldn't happen, but it doesn't hurt to make sure...
        cmp "$TARGET_FILE" "$TARGET_UNCOMPRESSED" || { \
            _erro "Decompressed file doesn't match original input"; \
            exit 1; \
        }

        rm -f "$TARGET_COMPRESSED" "$TARGET_UNCOMPRESSED"
    done
    echo ""
}

_info "Installing required utilities"
dnf install -qy lzop zstd pigz bc diffutils;

_info "Testing compression for 'zlib'"
test_compression 9 \
    'pigz -${level} -z -q -c "$TARGET_FILE" > "$TARGET_COMPRESSED"' \
    'pigz -d -q -c "$TARGET_COMPRESSED" > "$TARGET_UNCOMPRESSED"'

_info "Testing compression for 'zstd'"
test_compression 15 \
    'zstd -${level} -o "$TARGET_COMPRESSED" "$TARGET_FILE" 2>/dev/null' \
    'zstd -d -o "$TARGET_UNCOMPRESSED" "$TARGET_COMPRESSED" 2>/dev/null'

_info "Testing compression for 'lzo'"
test_compression 9 \
    'lzop -${level} -o${TARGET_COMPRESSED} "$TARGET_FILE"' \
    'lzop -d "$TARGET_COMPRESSED" -o${TARGET_UNCOMPRESSED}'


## Post-benchmark tasks
_info "Cleaning up..."
rm -rf "$TMPDIR"
_ok "Benchmark complete!"

