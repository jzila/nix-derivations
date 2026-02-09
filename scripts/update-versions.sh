#!/usr/bin/env bash
set -euo pipefail

# Update versions.json with latest versions and hashes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/../versions.json"

# Convert hex SHA256 to SRI format
hex_to_sri() {
    nix hash convert --hash-algo sha256 --to sri "$1"
}

update_beads() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        echo "Fetching latest beads version..."
        version=$(curl -s https://api.github.com/repos/steveyegge/beads/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    fi

    echo "Updating beads to $version..."

    local checksums
    checksums=$(curl -sL "https://github.com/steveyegge/beads/releases/download/v${version}/checksums.txt")

    local x86_64_linux aarch64_linux x86_64_darwin aarch64_darwin
    x86_64_linux=$(hex_to_sri "$(echo "$checksums" | grep "linux_amd64" | awk '{print $1}')")
    aarch64_linux=$(hex_to_sri "$(echo "$checksums" | grep "linux_arm64" | awk '{print $1}')")
    x86_64_darwin=$(hex_to_sri "$(echo "$checksums" | grep "darwin_amd64" | awk '{print $1}')")
    aarch64_darwin=$(hex_to_sri "$(echo "$checksums" | grep "darwin_arm64" | awk '{print $1}')")

    local tmp
    tmp=$(mktemp)
    jq --arg ver "$version" \
       --arg h1 "$x86_64_linux" \
       --arg h2 "$aarch64_linux" \
       --arg h3 "$x86_64_darwin" \
       --arg h4 "$aarch64_darwin" \
       '.beads.version = $ver |
        .beads.hashes["x86_64-linux"] = $h1 |
        .beads.hashes["aarch64-linux"] = $h2 |
        .beads.hashes["x86_64-darwin"] = $h3 |
        .beads.hashes["aarch64-darwin"] = $h4' \
       "$VERSIONS_FILE" > "$tmp"
    mv "$tmp" "$VERSIONS_FILE"

    echo "Updated beads to $version"
}

update_claude_code() {
    local version="${1:-}"
    local gcs_base="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

    if [[ -z "$version" ]]; then
        echo "Fetching latest claude-code version..."
        version=$(curl -sL "$gcs_base/latest")
    fi

    echo "Updating claude-code to $version..."

    local manifest
    manifest=$(curl -sL "$gcs_base/$version/manifest.json")

    local x86_64_linux aarch64_linux x86_64_darwin aarch64_darwin
    x86_64_linux=$(hex_to_sri "$(echo "$manifest" | jq -r '.platforms["linux-x64"].checksum')")
    aarch64_linux=$(hex_to_sri "$(echo "$manifest" | jq -r '.platforms["linux-arm64"].checksum')")
    x86_64_darwin=$(hex_to_sri "$(echo "$manifest" | jq -r '.platforms["darwin-x64"].checksum')")
    aarch64_darwin=$(hex_to_sri "$(echo "$manifest" | jq -r '.platforms["darwin-arm64"].checksum')")

    local tmp
    tmp=$(mktemp)
    jq --arg ver "$version" \
       --arg h1 "$x86_64_linux" \
       --arg h2 "$aarch64_linux" \
       --arg h3 "$x86_64_darwin" \
       --arg h4 "$aarch64_darwin" \
       '.["claude-code"].version = $ver |
        .["claude-code"].hashes["x86_64-linux"] = $h1 |
        .["claude-code"].hashes["aarch64-linux"] = $h2 |
        .["claude-code"].hashes["x86_64-darwin"] = $h3 |
        .["claude-code"].hashes["aarch64-darwin"] = $h4' \
       "$VERSIONS_FILE" > "$tmp"
    mv "$tmp" "$VERSIONS_FILE"

    echo "Updated claude-code to $version"
}

usage() {
    cat <<EOF
Update versions.json with latest versions and hashes for pinned packages.

Usage: $0 <command> [version]

Commands:
  beads [version]        Update beads (omit version for latest)
  claude-code [version]  Update claude-code (omit version for latest)
  all                    Update all packages to latest

Examples:
  $0 beads              # Update beads to latest
  $0 beads 0.50.0       # Pin beads to specific version
  $0 claude-code        # Update claude-code to latest
  $0 claude-code 2.2.0  # Pin claude-code to specific version
  $0 all                # Update all to latest
EOF
}

case "${1:-}" in
    beads)
        update_beads "${2:-}"
        ;;
    claude-code)
        update_claude_code "${2:-}"
        ;;
    all)
        update_beads "${2:-}"
        update_claude_code "${3:-}"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac
