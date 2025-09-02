#!/usr/bin/env bash

# EZ Flash - Helper script for flashing keyboard firmware
# Usage: ./ez.sh [bt60|corne-left|corne-right]
# Put the keyboard in flash mode after running this script

set -euo pipefail

# Default to bt60 for backward compatibility
KEYBOARD_TYPE="${1:-bt60}"

case "$KEYBOARD_TYPE" in
    "bt60")
        FIRMWARE_PATH="bt60_v2.uf2"
        KEYBOARD_NAME="BT60 v2"
        ;;
    "corne-left")
        FIRMWARE_PATH="corne_left.uf2"
        KEYBOARD_NAME="Corne (Left Half)"
        ;;
    "corne-right")
        FIRMWARE_PATH="corne_right.uf2"
        KEYBOARD_NAME="Corne (Right Half)"
        ;;
    *)
        echo "❌ Unknown keyboard type: $KEYBOARD_TYPE"
        echo "   Available options: bt60, corne-left, corne-right"
        echo "   Usage: ./ez.sh [bt60|corne-left|corne-right]"
        exit 1
        ;;
esac

EXPECTED_SIZE="32M"

echo "EZ Flash - $KEYBOARD_NAME Firmware Helper"
echo "==============================="
echo

# Check if firmware exists
if [ ! -f "$FIRMWARE_PATH" ]; then
    echo "❌ Firmware not found at: $FIRMWARE_PATH"
    case "$KEYBOARD_TYPE" in
        "bt60")
            echo "   Please build the firmware first with: just build bt60"
            echo "   (This should create bt60_v2.uf2 in the current directory)"
            ;;
        "corne-left")
            echo "   Please build the firmware first with: just build corne-left"
            echo "   (This should create corne_left.uf2 in the current directory)"
            ;;
        "corne-right")
            echo "   Please build the firmware first with: just build corne-right"
            echo "   (This should create corne_right.uf2 in the current directory)"
            ;;
    esac
    exit 1
fi

echo "✅ Firmware found: $FIRMWARE_PATH"
echo "   Size: $(du -h "$FIRMWARE_PATH" | cut -f1)"
echo

# Function to check for 32M devices
check_32m_devices() {
    # Use lsblk to find devices with SIZE around 32M (handles 32M, 32.1M, etc.)
    local devices
    devices=$(lsblk -o NAME,SIZE --noheadings | grep -E '\s+32(\.[0-9]+)?M$' | awk '{print $1}' || true)
    
    if [ -n "$devices" ]; then
        echo "Found 32M device(s):"
        # Show more details about the found devices
        while IFS= read -r device; do
            echo "  /dev/$device"
            lsblk -o NAME,SIZE,LABEL,MOUNTPOINT "/dev/$device" 2>/dev/null | tail -n +2 | sed 's/^/    /'
        done <<< "$devices"
        return 0
    else
        return 1
    fi
}

# Wait for user to put keyboard in flash mode
echo "⏳ Put your $KEYBOARD_NAME in flash mode now..."
case "$KEYBOARD_TYPE" in
    "bt60")
        echo "   (Hold the reset button or use the key combination)"
        ;;
    "corne-left"|"corne-right")
        echo "   (Double-tap the reset button on the Nice!Nano)"
        echo "   Make sure you're flashing the correct half!"
        ;;
esac
echo

while true; do
    if check_32m_devices; then
        echo
        break
    fi
    
    echo -n "."
    sleep 1
done

echo "🔍 32M device detected! Asking for confirmation..."
echo

# Get the first 32M device for confirmation
FLASH_DEVICE=$(lsblk -o NAME,SIZE --noheadings | grep -E '\s+32(\.[0-9]+)?M$' | awk '{print $1}' | head -n1)
FLASH_PATH="/dev/$FLASH_DEVICE"

# Use the confirm script for user interaction
if [ -x "$HOME/.local/bin/confirm" ]; then
    CONFIRM_CMD="$HOME/.local/bin/confirm"
else
    echo "❌ Confirm script not found at ~/.local/bin/confirm"
    exit 1
fi

# Prepare the flash command
FLASH_CMD="sudo cp '$FIRMWARE_PATH' '$FLASH_PATH' && sync && echo '✅ Firmware flashed successfully to $FLASH_PATH' && sudo umount '$FLASH_PATH' 2>/dev/null && echo '💾 Device safely unmounted'"

# Ask for confirmation and execute if approved
"$CONFIRM_CMD" "Flash firmware to $FLASH_PATH?" "$FLASH_CMD"

echo
echo "🎉 EZ Flash complete!"
echo "   Your keyboard should now be running the new firmware."