#!/usr/bin/env bash
# Convert TI ELF (.out) to Intel HEX or raw Binary
# Usage: bash scripts/convert.sh [firmware.out] [hex|bin] [output]
# Examples:
#   bash scripts/convert.sh
#   bash scripts/convert.sh firmware/my_app.out hex
#   bash scripts/convert.sh firmware/my_app.out bin firmware/my_app.bin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIRMWARE_RAW="${1:-$REPO_DIR/firmware/zero_code_start_ticlang.out}"
FORMAT="${2:-bin}"
OUTPUT_RAW="${3:-}"

TI_PATH=$(cygpath -w "/c/Users/Asus/guicomposer/runtime/gcruntime.v13/MSPZeroCodeStudio/ti_cgt_arm_llvm/bin")
TI_OBJCOPY="$TI_PATH\tiarmobjcopy.exe"
TI_HEX="$TI_PATH\tiarmhex.exe"

if [ ! -f "$FIRMWARE_RAW" ]; then
    echo "Error: Input file not found: $FIRMWARE_RAW"
    exit 1
fi

BASENAME=$(basename "$FIRMWARE_RAW" .out)

if [ -z "$OUTPUT_RAW" ]; then
    OUTPUT_RAW="$REPO_DIR/$BASENAME.$FORMAT"
fi
OUTPUT_WIN=$(cygpath -w "$OUTPUT_RAW" | sed 's|/|\\|g')
FIRMWARE_WIN=$(cygpath -w "$FIRMWARE_RAW" | sed 's|/|\\|g')

echo "=== Convert $FIRMWARE_RAW ==="
echo "Format : $FORMAT"
echo "Output : $OUTPUT_RAW"
echo ""

if [ "$FORMAT" = "bin" ]; then
    echo "Running tiarmobjcopy ..."
    "$TI_OBJCOPY" -O binary "$FIRMWARE_WIN" "$OUTPUT_WIN"
elif [ "$FORMAT" = "hex" ]; then
    echo "Running tiarmhex ..."
    "$TI_HEX" "$FIRMWARE_WIN" "-o" "$OUTPUT_WIN"
else
    echo "Error: Unsupported format '$FORMAT'. Use 'hex' or 'bin'."
    exit 1
fi

SIZE=$(wc -c < "$OUTPUT_RAW" | tr -d ' ')
echo ""
echo "Done! Output: $OUTPUT_RAW ($SIZE bytes)"
