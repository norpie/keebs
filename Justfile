# Initialize west workspace
init:
    west init -l config

# Update west dependencies  
update:
    west update

# Build firmware for bt60_v2
build:
    west build -p -s zmk/app -b bt60_v2

# Clean build artifacts
clean:
    rm -rf build

# Clean everything including west modules
clean-all: clean
    rm -rf .west modules tools zephyr bootloader

# List available commands
list:
    @just --list