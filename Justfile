# Initialize west workspace
init:
    west init -l config

# Update west dependencies  
update:
    west update

# Build firmware (default: bt60, options: bt60, corne-left, corne-right)
build keyboard="bt60":
    #!/usr/bin/env bash
    case "{{keyboard}}" in
        "bt60")
            west build -p -s zmk/app -b bt60_v2 -- -DZMK_CONFIG="$(pwd)/config/bt60"
            ;;
        "corne-left")
            west build -p -s zmk/app -b nice_nano_v2 -S corne_left -- -DZMK_CONFIG="$(pwd)/config/corne"
            ;;
        "corne-right")
            west build -p -s zmk/app -b nice_nano_v2 -S corne_right -- -DZMK_CONFIG="$(pwd)/config/corne"
            ;;
        *)
            echo "Unknown keyboard: {{keyboard}}"
            echo "Available options: bt60, corne-left, corne-right"
            exit 1
            ;;
    esac

# Clean build artifacts
clean:
    rm -rf build

# Clean everything including west modules
clean-all: clean
    rm -rf .west modules tools zephyr bootloader

# List available commands
list:
    @just --list