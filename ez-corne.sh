#!/usr/bin/env bash

# EZ Flash Corne - Helper script for flashing both Corne halves
# Usage: ./ez-corne.sh
# This script will guide you through flashing both halves sequentially

set -euo pipefail

echo "EZ Flash - Corne Firmware Helper"
echo "================================="
echo
echo "This script will help you flash both halves of your Corne keyboard."
echo "You'll need to flash the left and right halves separately."
echo
echo "Make sure you have built the Corne firmware first:"
echo "  just build corne"
echo
echo "This should have created both corne_left.uf2 and corne_right.uf2 files."
echo

# Check if both firmware files exist
if [ ! -f "corne_left.uf2" ] || [ ! -f "corne_right.uf2" ]; then
    echo "❌ Missing Corne firmware files!"
    echo "   Expected: corne_left.uf2 and corne_right.uf2"
    echo "   Please build the firmware first with: just build corne"
    exit 1
fi

echo "✅ Both firmware files found:"
echo "   Left:  corne_left.uf2  ($(du -h corne_left.uf2 | cut -f1))"
echo "   Right: corne_right.uf2 ($(du -h corne_right.uf2 | cut -f1))"
echo

# Function to ask user which half to start with
ask_start_half() {
    echo "🤔 Which half would you like to flash first?" >&2
    echo "   1) Left half" >&2
    echo "   2) Right half" >&2
    echo >&2
    echo -n "👉 Enter your choice (1 or 2): " >&2
    read -r choice
    
    case "$choice" in
        "1")
            echo "left"
            ;;
        "2")
            echo "right"
            ;;
        *)
            echo "❌ Invalid choice. Please enter 1 or 2." >&2
            ask_start_half
            ;;
    esac
}

# Get user's preference for starting half
FIRST_HALF=$(ask_start_half)

if [ "$FIRST_HALF" = "left" ]; then
    SECOND_HALF="right"
else
    SECOND_HALF="left"
fi

echo
echo "📋 Flashing sequence:"
echo "1. Flash $FIRST_HALF half first"
echo "2. Flash $SECOND_HALF half second"
echo

# Flash first half
echo "🚀 Starting with $FIRST_HALF half..."
echo
echo "📋 Before pressing Enter:"
echo "   1. Connect ONLY the $FIRST_HALF half to your computer via USB"
echo "   2. Make sure the other half is disconnected"
echo "   3. Have the $FIRST_HALF half ready to put in flash mode"
echo
echo "Press Enter when the $FIRST_HALF half is connected and ready..."
read -r

if ! ./ez.sh "corne-$FIRST_HALF"; then
    echo "❌ Flash script returned error for $FIRST_HALF half"
    echo "   Note: If the firmware was actually flashed successfully,"
    echo "   you can continue manually with: ./ez.sh corne-$SECOND_HALF"
    exit 1
fi

echo
echo "✅ $FIRST_HALF half flashed successfully!"
echo
echo "🔄 Now let's flash the $SECOND_HALF half..."
echo
echo "📋 Before pressing Enter:"
echo "   1. Disconnect the $FIRST_HALF half from your computer"
echo "   2. Connect ONLY the $SECOND_HALF half to your computer via USB"
echo "   3. Have the $SECOND_HALF half ready to put in flash mode"
echo
echo "Press Enter when the $SECOND_HALF half is connected and ready..."
read -r

if ! ./ez.sh "corne-$SECOND_HALF"; then
    echo "❌ Flash script returned error for $SECOND_HALF half"
    echo "   Note: If the firmware was actually flashed successfully,"
    echo "   the process is complete despite the error message."
    exit 1
fi

echo
echo "🎉 Both Corne halves flashed successfully!"
echo
echo "Your Corne keyboard should now be running the new firmware."
echo "Remember to pair both halves with your computer if this is a fresh flash."