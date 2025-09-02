#!/usr/bin/env bash

# EZ Flash Corne - Automated script for flashing both Corne halves
# Usage: ./ez-corne.sh [left|right]
# If no argument provided, defaults to flashing left then right

set -euo pipefail

# Default order: left first, then right
FIRST_HALF="${1:-left}"
if [ "$FIRST_HALF" = "left" ]; then
    SECOND_HALF="right"
elif [ "$FIRST_HALF" = "right" ]; then
    SECOND_HALF="left"
else
    echo "❌ Invalid argument. Use 'left' or 'right', or no argument for default (left first)"
    exit 1
fi

echo "EZ Flash - Corne Firmware Helper"
echo "================================="
echo
echo "Automated flashing of both Corne halves"
echo "Order: $FIRST_HALF half first, then $SECOND_HALF half"
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

# Flash first half
echo "🚀 Flashing $FIRST_HALF half..."
echo "📋 Make sure ONLY the $FIRST_HALF half is connected via USB"

if ! ./ez.sh "corne-$FIRST_HALF"; then
    echo "❌ Flash failed for $FIRST_HALF half"
    echo "   You can continue manually with: ./ez.sh corne-$SECOND_HALF"
    exit 1
fi

echo
echo "✅ $FIRST_HALF half flashed successfully!"
echo
echo "🔄 Now flashing $SECOND_HALF half..."
echo "📋 Switch USB cable to the $SECOND_HALF half and put it in flash mode"

if ! ./ez.sh "corne-$SECOND_HALF"; then
    echo "❌ Flash failed for $SECOND_HALF half"
    echo "   Note: $FIRST_HALF half was flashed successfully"
    exit 1
fi

echo
echo "🎉 Both Corne halves flashed successfully!"
echo "Your Corne keyboard should now be running the new firmware."