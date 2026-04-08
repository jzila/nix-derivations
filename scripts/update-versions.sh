#!/usr/bin/env bash
set -euo pipefail

# Update versions.json with latest versions and hashes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/../versions.json"

# Convert hex SHA256 to SRI format
hex_to_sri() {
    nix hash convert --hash-algo sha256 --to sri "$1"
}

update_nsc() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        echo "Fetching latest nsc version..."
        version=$(curl -sL https://api.github.com/repos/namespacelabs/foundation/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    fi

    echo "Updating nsc to $version..."

    local checksums
    checksums=$(curl -sL "https://github.com/namespacelabs/foundation/releases/download/v${version}/checksums.txt")

    local x86_64_linux aarch64_linux x86_64_darwin aarch64_darwin
    x86_64_linux=$(hex_to_sri "$(echo "$checksums" | grep "nsc_.*linux_amd64" | awk '{print $1}')")
    aarch64_linux=$(hex_to_sri "$(echo "$checksums" | grep "nsc_.*linux_arm64" | awk '{print $1}')")
    x86_64_darwin=$(hex_to_sri "$(echo "$checksums" | grep "nsc_.*darwin_amd64" | awk '{print $1}')")
    aarch64_darwin=$(hex_to_sri "$(echo "$checksums" | grep "nsc_.*darwin_arm64" | awk '{print $1}')")

    local tmp
    tmp=$(mktemp)
    jq --arg ver "$version" \
       --arg h1 "$x86_64_linux" \
       --arg h2 "$aarch64_linux" \
       --arg h3 "$x86_64_darwin" \
       --arg h4 "$aarch64_darwin" \
       '.nsc.version = $ver |
        .nsc.hashes["x86_64-linux"] = $h1 |
        .nsc.hashes["aarch64-linux"] = $h2 |
        .nsc.hashes["x86_64-darwin"] = $h3 |
        .nsc.hashes["aarch64-darwin"] = $h4' \
       "$VERSIONS_FILE" > "$tmp"
    mv "$tmp" "$VERSIONS_FILE"

    echo "Updated nsc to $version"
}

update_devbox() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        echo "Fetching latest devbox version..."
        version=$(curl -sL https://api.github.com/repos/namespacelabs/devbox/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    fi

    echo "Updating devbox to $version..."

    local checksums
    checksums=$(curl -sL "https://github.com/namespacelabs/devbox/releases/download/v${version}/devbox_checksums.txt")

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
       '.devbox.version = $ver |
        .devbox.hashes["x86_64-linux"] = $h1 |
        .devbox.hashes["aarch64-linux"] = $h2 |
        .devbox.hashes["x86_64-darwin"] = $h3 |
        .devbox.hashes["aarch64-darwin"] = $h4' \
       "$VERSIONS_FILE" > "$tmp"
    mv "$tmp" "$VERSIONS_FILE"

    echo "Updated devbox to $version"
}

update_beads() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        echo "Fetching latest beads version..."
        version=$(curl -sL https://api.github.com/repos/gastownhall/beads/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    fi

    echo "Updating beads to $version..."

    local checksums
    checksums=$(curl -sL "https://github.com/gastownhall/beads/releases/download/v${version}/checksums.txt")

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

update_gh_dash() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        echo "Fetching latest gh-dash version..."
        version=$(curl -sL https://api.github.com/repos/dlvhdr/gh-dash/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    fi

    echo "Updating gh-dash to $version..."

    local checksums
    checksums=$(curl -sL "https://github.com/dlvhdr/gh-dash/releases/download/v${version}/checksums.txt")

    local x86_64_linux aarch64_linux x86_64_darwin aarch64_darwin
    x86_64_linux=$(hex_to_sri "$(echo "$checksums" | grep "linux-amd64" | awk '{print $1}')")
    aarch64_linux=$(hex_to_sri "$(echo "$checksums" | grep "linux-arm64" | awk '{print $1}')")
    x86_64_darwin=$(hex_to_sri "$(echo "$checksums" | grep "darwin-amd64" | awk '{print $1}')")
    aarch64_darwin=$(hex_to_sri "$(echo "$checksums" | grep "darwin-arm64" | awk '{print $1}')")

    local tmp
    tmp=$(mktemp)
    jq --arg ver "$version" \
       --arg h1 "$x86_64_linux" \
       --arg h2 "$aarch64_linux" \
       --arg h3 "$x86_64_darwin" \
       --arg h4 "$aarch64_darwin" \
       '.["gh-dash"].version = $ver |
        .["gh-dash"].hashes["x86_64-linux"] = $h1 |
        .["gh-dash"].hashes["aarch64-linux"] = $h2 |
        .["gh-dash"].hashes["x86_64-darwin"] = $h3 |
        .["gh-dash"].hashes["aarch64-darwin"] = $h4' \
       "$VERSIONS_FILE" > "$tmp"
    mv "$tmp" "$VERSIONS_FILE"

    echo "Updated gh-dash to $version"
}

update_signoz_mcp_server() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        echo "Fetching latest signoz-mcp-server version..."
        version=$(curl -sL https://api.github.com/repos/SigNoz/signoz-mcp-server/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    fi

    echo "Updating signoz-mcp-server to $version..."

    local checksums
    checksums=$(curl -sL "https://github.com/SigNoz/signoz-mcp-server/releases/download/v${version}/signoz-mcp-server_${version}_checksums.txt")

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
       '.["signoz-mcp-server"].version = $ver |
        .["signoz-mcp-server"].hashes["x86_64-linux"] = $h1 |
        .["signoz-mcp-server"].hashes["aarch64-linux"] = $h2 |
        .["signoz-mcp-server"].hashes["x86_64-darwin"] = $h3 |
        .["signoz-mcp-server"].hashes["aarch64-darwin"] = $h4' \
       "$VERSIONS_FILE" > "$tmp"
    mv "$tmp" "$VERSIONS_FILE"

    echo "Updated signoz-mcp-server to $version"
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
  nsc [version]          Update nsc (omit version for latest)
  devbox [version]       Update devbox (omit version for latest)
  beads [version]        Update beads (omit version for latest)
  gh-dash [version]     Update gh-dash (omit version for latest)
  signoz-mcp-server [version]  Update signoz-mcp-server (omit version for latest)
  claude-code [version]  Update claude-code (omit version for latest)
  all                    Update all packages to latest

Examples:
  $0 nsc                # Update nsc to latest
  $0 nsc 0.0.489        # Pin nsc to specific version
  $0 devbox             # Update devbox to latest
  $0 devbox 0.0.116     # Pin devbox to specific version
  $0 beads              # Update beads to latest
  $0 beads 0.50.0       # Pin beads to specific version
  $0 gh-dash            # Update gh-dash to latest
  $0 gh-dash 4.23.2     # Pin gh-dash to specific version
  $0 signoz-mcp-server  # Update signoz-mcp-server to latest
  $0 signoz-mcp-server 0.0.5  # Pin signoz-mcp-server to specific version
  $0 claude-code        # Update claude-code to latest
  $0 claude-code 2.2.0  # Pin claude-code to specific version
  $0 all                # Update all to latest
EOF
}

case "${1:-}" in
    nsc)
        update_nsc "${2:-}"
        ;;
    devbox)
        update_devbox "${2:-}"
        ;;
    beads)
        update_beads "${2:-}"
        ;;
    gh-dash)
        update_gh_dash "${2:-}"
        ;;
    signoz-mcp-server)
        update_signoz_mcp_server "${2:-}"
        ;;
    claude-code)
        update_claude_code "${2:-}"
        ;;
    all)
        update_nsc "${2:-}"
        update_devbox "${3:-}"
        update_beads "${4:-}"
        update_gh_dash "${5:-}"
        update_signoz_mcp_server "${6:-}"
        update_claude_code "${7:-}"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac
