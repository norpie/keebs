#!/usr/bin/env bash

# EZ Flash Corne - Automated script for flashing both Corne halves
# Usage: ./ez-corne.sh [left|right] [--reset]
# If no argument provided, defaults to flashing left then right
# Use --reset to flash reset firmware first, then normal firmware

set -euo pipefail

# Parse arguments
RESET_MODE=false
FIRST_HALF=""

for arg in "$@"; do
    case $arg in
        --reset)
            RESET_MODE=true
            ;;
        left|right)
            FIRST_HALF="$arg"
            ;;
        *)
            echo "❌ Unknown argument: $arg"
            echo "   Usage: ./ez-corne.sh [left|right] [--reset]"
            exit 1
            ;;
    esac
done

# Default order: left first, then right
FIRST_HALF="${FIRST_HALF:-left}"
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
if [ "$RESET_MODE" = true ]; then
    echo "🔄 RESET MODE: Will flash reset firmware first, then normal firmware"
else
    echo "Automated flashing of both Corne halves"
fi
echo "Order: $FIRST_HALF half first, then $SECOND_HALF half"
echo

# Build firmware based on mode
if [ "$RESET_MODE" = true ]; then
    echo "Building reset and normal firmware..."
    just reset corne || {
        echo "❌ 'just reset corne' failed. Please fix build issues first."
        exit 1
    }
    just build corne || {
        echo "❌ 'just build corne' failed. Please fix build issues first."
        exit 1
    }
    
    # Check if all firmware files exist
    if [ ! -f "corne_reset.uf2" ] || [ ! -f "corne_left.uf2" ] || [ ! -f "corne_right.uf2" ]; then
        echo "❌ Missing firmware files!"
        echo "   Expected: corne_reset.uf2, corne_left.uf2, and corne_right.uf2"
        exit 1
    fi
else
    just build corne || {
        echo "❌ 'just build corne' failed. Please fix build issues first."
        exit 1
    }
    
    # Check if both firmware files exist
    if [ ! -f "corne_left.uf2" ] || [ ! -f "corne_right.uf2" ]; then
        echo "❌ Missing Corne firmware files!"
        echo "   Expected: corne_left.uf2 and corne_right.uf2"
        echo "   Please build the firmware first with: just build corne"
        exit 1
    fi
fi

if [ "$RESET_MODE" = true ]; then
    echo "✅ All firmware files found:"
    echo "   Reset: corne_reset.uf2    ($(du -h corne_reset.uf2 | cut -f1))"
    echo "   Left:  corne_left.uf2    ($(du -h corne_left.uf2 | cut -f1))"
    echo "   Right: corne_right.uf2   ($(du -h corne_right.uf2 | cut -f1))"
else
    echo "✅ Both firmware files found:"
    echo "   Left:  corne_left.uf2  ($(du -h corne_left.uf2 | cut -f1))"
    echo "   Right: corne_right.uf2 ($(du -h corne_right.uf2 | cut -f1))"
fi
echo

if [ "$RESET_MODE" = true ]; then
    # Flash reset firmware first
    echo "🔄 STEP 1/3: Flashing reset firmware to $FIRST_HALF half..."
    echo "📋 Make sure ONLY the $FIRST_HALF half is connected via USB"
    
    if ! ./ez.sh "corne-reset"; then
        echo "❌ Reset flash failed for $FIRST_HALF half"
        exit 1
    fi
    
    echo
    echo "✅ Reset firmware flashed to $FIRST_HALF half!"
    echo
    echo "🔄 STEP 2/3: Flashing reset firmware to $SECOND_HALF half..."
    echo "📋 Switch USB cable to the $SECOND_HALF half and put it in flash mode"
    
    if ! ./ez.sh "corne-reset"; then
        echo "❌ Reset flash failed for $SECOND_HALF half"
        exit 1
    fi
    
    echo
    echo "✅ Reset firmware flashed to both halves!"
    echo
    echo "🔄 STEP 3/3: Now flashing normal firmware..."
    echo "📋 Switch back to the $FIRST_HALF half and put it in flash mode"
fi

# Flash normal firmware
if [ "$RESET_MODE" = true ]; then
    echo "🚀 Flashing normal firmware to $FIRST_HALF half..."
else
    echo "🚀 Flashing $FIRST_HALF half..."
fi
echo "📋 Make sure ONLY the $FIRST_HALF half is connected via USB"

if ! ./ez.sh "corne-$FIRST_HALF"; then
    echo "❌ Flash failed for $FIRST_HALF half"
    echo "   You can continue manually with: ./ez.sh corne-$SECOND_HALF"
    exit 1
fi

echo
echo "✅ $FIRST_HALF half flashed successfully!"
echo
if [ "$RESET_MODE" = true ]; then
    echo "🔄 Now flashing normal firmware to $SECOND_HALF half..."
else
    echo "🔄 Now flashing $SECOND_HALF half..."
fi
echo "📋 Switch USB cable to the $SECOND_HALF half and put it in flash mode"

if ! ./ez.sh "corne-$SECOND_HALF"; then
    echo "❌ Flash failed for $SECOND_HALF half"
    echo "   Note: $FIRST_HALF half was flashed successfully"
    exit 1
fi

echo
echo "🎉 Both Corne halves flashed successfully!"
if [ "$RESET_MODE" = true ]; then
    echo "Reset complete! Your Corne keyboard should now be running the new firmware."
    echo "You may need to re-pair with your devices."
else
    echo "Your Corne keyboard should now be running the new firmware."
fi
