# Initialize west workspace
init:
    west init -l config

# Update west dependencies  
update:
    west update

# Build firmware (default: bt60, options: bt60, corne, corne-left, corne-right)
build keyboard="bt60":
    #!/usr/bin/env bash
    case "{{keyboard}}" in
        "bt60")
            west build -p -s zmk/app -b bt60_v2 -- -DZMK_CONFIG="$(pwd)/config/bt60"
            cp build/zephyr/zmk.uf2 bt60_v2.uf2
            echo "Firmware built: bt60_v2.uf2"
            ;;
        "corne")
            # Build left side
            west build -p -s zmk/app -b nice_nano_v2 -- -DSHIELD="corne_left nice_view_adapter nice_view" -DZMK_CONFIG="$(pwd)/config/corne"
            cp build/zephyr/zmk.uf2 corne_left.uf2
            echo "Built left side: corne_left.uf2"
            # Build right side
            west build -p -s zmk/app -b nice_nano_v2 -- -DSHIELD="corne_right nice_view_adapter nice_view" -DZMK_CONFIG="$(pwd)/config/corne"
            cp build/zephyr/zmk.uf2 corne_right.uf2
            echo "Built right side: corne_right.uf2"
            echo "Firmware built: corne_left.uf2 & corne_right.uf2"
            ;;
        "corne-left")
            west build -p -s zmk/app -b nice_nano_v2 -- -DSHIELD="corne_left nice_view_adapter nice_view" -DZMK_CONFIG="$(pwd)/config/corne"
            cp build/zephyr/zmk.uf2 corne_left.uf2
            echo "Firmware built: corne_left.uf2"
            ;;
        "corne-right")
            west build -p -s zmk/app -b nice_nano_v2 -- -DSHIELD="corne_right nice_view_adapter nice_view" -DZMK_CONFIG="$(pwd)/config/corne"
            cp build/zephyr/zmk.uf2 corne_right.uf2
            echo "Firmware built: corne_right.uf2"
            ;;
        *)
            echo "Unknown keyboard: {{keyboard}}"
            echo "Available options: bt60, corne, corne-left, corne-right"
            exit 1
            ;;
    esac

# Clean build artifacts
clean:
    rm -rf build
    rm -f *.uf2

# Clean everything including west modules
clean-all: clean
    rm -rf .west modules tools zephyr bootloader

# Generate keymap layer previews (options: all, bt60, corne)
keymap keyboard="all":
    ./scripts/generate-keymap-previews.sh {{keyboard}}

# List available commands
list:
    @just --list