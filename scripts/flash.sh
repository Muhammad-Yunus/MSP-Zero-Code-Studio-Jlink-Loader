#!/usr/bin/env bash
# Flash firmware to MSPM0G3507 via J-Link (GDB method)
# Usage: bash scripts/flash.sh [firmware.out]
# Default firmware: firmware/zero_code_start_ticlang.out

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIRMWARE_RAW="${2:-$REPO_DIR/firmware/zero_code_start_ticlang.out}"
FIRMWARE_WIN=$(cygpath -w "$FIRMWARE_RAW" | sed 's|/|\\|g')

# Convert to Windows forward-slash path for GDB: C:/D/...
FIRMWARE_GDB=$(echo "$FIRMWARE_RAW" | sed 's#^/c/#C:/#')

JLINK_PATH=$(cygpath -w "/c/Program Files/SEGGER/JLink_V844/JLinkGDBServer.exe")

# Auto-detect GDB from common locations (PATH > TI ARM GCC bundled with CCS/MSP Zero)
# NOTE: MSP Zero Code Studio does NOT bundle GDB. TI ARM GCC is included with CCS installs.
_GDB_CANDIDATES=(
  # TI ARM GCC — bundled with CCS / MSP Zero Code Studio at C:\ti\gcc-arm-none-eabi-*
  "/c/ti/gcc-arm-none-eabi-*/bin/arm-none-eabi-gdb.exe"
)
GDB_PATH=""
for _gdb in "${_GDB_CANDIDATES[@]}"; do
  for _match in $_gdb; do
    if [ -f "$_match" ]; then
      GDB_PATH=$(cygpath -w "$_match")
      break 2
    fi
  done
done
if [ -z "$GDB_PATH" ]; then
  _which_gdb=$(which arm-none-eabi-gdb 2>/dev/null)
  GDB_PATH=$(cygpath -w "$_which_gdb" 2>/dev/null || echo "")
fi
PORT="${PORT:-2331}"

if [ ! -f "$FIRMWARE_RAW" ]; then
    echo "Error: Firmware not found: $FIRMWARE_RAW"
    exit 1
fi

echo "=== MSPM0G3507 Flash via J-Link ==="
echo "Firmware : $FIRMWARE_RAW"
echo "JLinkGDBServer : $JLINK_PATH"
echo "GDB            : $GDB_PATH"
echo ""

# Start JLinkGDBServer in background
echo "[1/2] Starting JLinkGDBServer on port $PORT ..."
"$JLINK_PATH" -device MSPM0G3507 -if SWD -speed auto -port "$PORT" -singlerun &
JLINK_PID=$!
echo "       PID: $JLINK_PID"

# Wait for server to be ready
sleep 3

# Flash via GDB
echo "[2/2] Flashing firmware via GDB ..."
"$GDB_PATH" -q \
  --eval-command="set confirm off" \
  --eval-command="target extended-remote :$PORT" \
  --eval-command="file $FIRMWARE_GDB" \
  --eval-command="load" \
  --eval-command="kill"

# Clean up JLinkGDBServer
wait "$JLINK_PID" 2>/dev/null || true
powershell -Command "Get-Process JLinkGDBServer -ErrorAction SilentlyContinue | Stop-Process -Force" 2>/dev/null || true

echo ""
echo "Done! Firmware flashed to MSPM0G3507."
