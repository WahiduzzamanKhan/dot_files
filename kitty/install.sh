#!/usr/bin/env bash
#
# Install kitty if missing, otherwise offer to upgrade it when a newer
# version is available. Then replace the default app icon with a custom one.
#
# Usage: ./install.sh [--icon path/to/icon.icns|png]
#
# Without --icon the icon is looked up next to this script as
# kitty.app.icns or kitty.app.png.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${KITTY_CONFIG_DIRECTORY:-$HOME/.config/kitty}"
VERSION_URL="https://sw.kovidgoyal.net/kitty/current-version.txt"
INSTALLER_URL="https://sw.kovidgoyal.net/kitty/installer.sh"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [--icon PATH]

Options:
  -i, --icon PATH  Custom app icon (.icns or .png). Defaults to kitty.app.icns
                   or kitty.app.png next to this script.
  -h, --help       Show this help.
EOF
}

[[ "$(uname -s)" == "Darwin" ]] || die "This script only supports macOS."

has_brew() { command -v brew >/dev/null 2>&1; }

find_app() {
    local app
    for app in "/Applications/kitty.app" "$HOME/Applications/kitty.app"; do
        if [[ -d "$app" ]]; then
            echo "$app"
            return 0
        fi
    done
    return 1
}

installed_version() {
    /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$1/Contents/Info.plist"
}

latest_version() {
    curl -fsSL "$VERSION_URL"
}

# True if $1 is strictly older than $2.
version_lt() {
    [[ "$1" != "$2" && "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$1" ]]
}

managed_by_brew() {
    has_brew && brew list --cask kitty >/dev/null 2>&1
}

install_kitty() {
    if has_brew; then
        info "Installing kitty with Homebrew..."
        brew install --cask kitty
    else
        info "Installing kitty with the official installer..."
        curl -fsSL "$INSTALLER_URL" | sh /dev/stdin launch=n
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/Applications/kitty.app/Contents/MacOS/kitty" "$HOME/.local/bin/kitty"
        ln -sf "$HOME/Applications/kitty.app/Contents/MacOS/kitten" "$HOME/.local/bin/kitten"
    fi
}

upgrade_kitty() {
    if managed_by_brew; then
        brew upgrade --cask kitty
    else
        # The official installer replaces ~/Applications/kitty.app in place.
        curl -fsSL "$INSTALLER_URL" | sh /dev/stdin launch=n
    fi
}

check_for_update() {
    local app="$1" current latest answer
    current="$(installed_version "$app")"

    if ! latest="$(latest_version)"; then
        warn "Could not fetch the latest version; skipping the update check."
        return
    fi

    info "Installed: $current, latest: $latest"
    if ! version_lt "$current" "$latest"; then
        info "kitty is up to date."
        return
    fi

    read -r -p "kitty $latest is available. Install it now? [y/N] " answer
    case "$answer" in
        [yY] | [yY][eE][sS]) upgrade_kitty ;;
        *) info "Skipping update." ;;
    esac
}

resolve_icon() {
    local candidate
    if [[ -n "$1" ]]; then
        [[ -f "$1" ]] || die "Icon not found: $1"
        echo "$1"
        return 0
    fi
    for candidate in "$SCRIPT_DIR/kitty.app.icns" "$SCRIPT_DIR/kitty.app.png"; do
        if [[ -f "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

apply_icon() {
    local app="$1" icon="$2" ext
    ext="${icon##*.}"
    ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
    [[ "$ext" == "icns" || "$ext" == "png" ]] || die "Icon must be a .icns or .png file."

    # kitty re-applies this icon on every launch, so it survives upgrades
    # that replace the app bundle.
    mkdir -p "$CONFIG_DIR"
    rm -f "$CONFIG_DIR/kitty.app.icns" "$CONFIG_DIR/kitty.app.png"
    cp "$icon" "$CONFIG_DIR/kitty.app.$ext"
    info "Copied icon to $CONFIG_DIR/kitty.app.$ext"

    # Apply it right away too, so it shows before kitty is first launched.
    osascript -l JavaScript - "$icon" "$app" <<'JXA' >/dev/null
ObjC.import("AppKit");
function run(argv) {
    const image = $.NSImage.alloc.initWithContentsOfFile(argv[0]);
    if (!image.isValid) throw new Error("Invalid image: " + argv[0]);
    if (!$.NSWorkspace.sharedWorkspace.setIconForFileOptions(image, argv[1], 0))
        throw new Error("Could not set icon on " + argv[1]);
}
JXA

    touch "$app"
    killall Dock 2>/dev/null || true
    info "Applied custom icon to $app"
}

main() {
    local app icon icon_arg=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i | --icon)
                [[ $# -ge 2 && -n "$2" ]] || die "$1 requires a path."
                icon_arg="$2"
                shift 2
                ;;
            --icon=*)
                icon_arg="${1#*=}"
                shift
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                usage >&2
                die "Unknown argument: $1"
                ;;
        esac
    done

    # Expand a quoted leading ~ and validate before doing any install work.
    icon_arg="${icon_arg/#\~/$HOME}"
    [[ -z "$icon_arg" || -f "$icon_arg" ]] || die "Icon not found: $icon_arg"

    if app="$(find_app)"; then
        info "kitty found at $app"
        check_for_update "$app"
    else
        install_kitty
    fi

    app="$(find_app)" || die "kitty.app not found after install."

    if icon="$(resolve_icon "$icon_arg")"; then
        apply_icon "$app" "$icon"
    else
        warn "No icon found. Put kitty.app.icns or kitty.app.png in $SCRIPT_DIR or pass --icon PATH."
    fi
}

main "$@"
