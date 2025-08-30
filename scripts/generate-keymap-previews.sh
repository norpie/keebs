#!/usr/bin/env bash

# Generate keymap layer previews for both keyboards using keymap-drawer
# This script parses ZMK keymaps and generates SVG visualizations

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_ROOT/config"
KEYMAP_DRAWER_DIR="$PROJECT_ROOT/keymap-drawer"
OUTPUT_DIR="$PROJECT_ROOT/keymap-previews"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if keymap-drawer is installed
check_dependencies() {
    if ! command -v keymap >/dev/null 2>&1; then
        log_error "keymap-drawer not found. Install with: pipx install keymap-drawer"
        exit 1
    fi
    log_info "Found keymap-drawer: $(keymap --version)"
}

# Create output directory
setup_output_dir() {
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        mkdir -p "$OUTPUT_DIR"
        log_info "Created output directory: $OUTPUT_DIR"
    fi
}

# Generate keymap preview for BT60
generate_bt60_preview() {
    log_info "Generating BT60 keymap preview..."
    
    local keymap_file="$CONFIG_DIR/bt60/bt60_v2.keymap"
    local layout_config="$KEYMAP_DRAWER_DIR/bt60.yaml"
    local output_file="$OUTPUT_DIR/bt60-layers.svg"
    local parsed_yaml="$OUTPUT_DIR/bt60-parsed.yaml"
    
    if [[ ! -f "$keymap_file" ]]; then
        log_error "BT60 keymap file not found: $keymap_file"
        return 1
    fi
    
    # Parse the keymap file to YAML
    log_info "Parsing BT60 keymap..."
    if keymap parse -c 10 -z "$keymap_file" > "$parsed_yaml"; then
        log_success "BT60 keymap parsed successfully"
    else
        log_error "Failed to parse BT60 keymap"
        return 1
    fi
    
    # Generate SVG visualization
    log_info "Generating BT60 SVG..."
    # Generate with layer names visible
    if keymap draw -o "$output_file" "$parsed_yaml"; then
        log_success "BT60 keymap preview generated: $output_file"
        log_info "Layers: default, fn, bluetooth, gaming"
    else
        log_error "Failed to generate BT60 preview"
        return 1
    fi
}

# Generate keymap preview for Corne
generate_corne_preview() {
    log_info "Generating Corne keymap preview..."
    
    local keymap_file="$CONFIG_DIR/corne/corne.keymap"
    local layout_config="$KEYMAP_DRAWER_DIR/corne.yaml"
    local output_file="$OUTPUT_DIR/corne-layers.svg"
    local parsed_yaml="$OUTPUT_DIR/corne-parsed.yaml"
    
    if [[ ! -f "$keymap_file" ]]; then
        log_error "Corne keymap file not found: $keymap_file"
        return 1
    fi
    
    # Parse the keymap file to YAML
    log_info "Parsing Corne keymap..."
    if keymap parse -c 10 -z "$keymap_file" > "$parsed_yaml"; then
        # Update the parsed YAML to use corneish_zen layout
        sed -i 's/layout: {zmk_keyboard: corne}/layout: {zmk_keyboard: corneish_zen}/' "$parsed_yaml"
        log_success "Corne keymap parsed successfully"
    else
        log_error "Failed to parse Corne keymap"
        return 1
    fi
    
    # Generate SVG visualization
    log_info "Generating Corne SVG..."
    if keymap draw -o "$output_file" "$parsed_yaml"; then
        log_success "Corne keymap preview generated: $output_file"
        log_info "Layers: Base (only one layer defined in keymap)"
    else
        log_error "Failed to generate Corne preview"
        return 1
    fi
}

# Main function
main() {
    log_info "Starting keymap preview generation..."
    
    check_dependencies
    setup_output_dir
    
    local bt60_success=false
    local corne_success=false
    
    # Generate previews
    if generate_bt60_preview; then
        bt60_success=true
    fi
    
    if generate_corne_preview; then
        corne_success=true
    fi
    
    # Summary
    echo
    log_info "Generation Summary:"
    if $bt60_success; then
        log_success "✓ BT60 preview generated"
    else
        log_error "✗ BT60 preview failed"
    fi
    
    if $corne_success; then
        log_success "✓ Corne preview generated"
    else
        log_error "✗ Corne preview failed"
    fi
    
    if $bt60_success || $corne_success; then
        echo
        log_success "Keymap previews are available in: $OUTPUT_DIR"
        log_info "Open the SVG files in a web browser or vector graphics editor to view the layer diagrams."
    fi
    
    # Exit with error if both failed
    if ! $bt60_success && ! $corne_success; then
        exit 1
    fi
}

# Handle script arguments
case "${1:-all}" in
    bt60)
        log_info "Generating BT60 preview only..."
        check_dependencies
        setup_output_dir
        generate_bt60_preview
        ;;
    corne)
        log_info "Generating Corne preview only..."
        check_dependencies
        setup_output_dir
        generate_corne_preview
        ;;
    all|*)
        main
        ;;
esac