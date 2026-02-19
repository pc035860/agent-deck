#!/bin/bash
#
# agent-deck-switch - Switch between local build and official release
#
# Usage:
#   agent-deck-switch          # Show current version and toggle
#   agent-deck-switch local    # Switch to local build
#   agent-deck-switch official # Switch to official release
#   agent-deck-switch status   # Show current status only
#

BIN_DIR="$HOME/.local/bin"
LINK="$BIN_DIR/agent-deck"
LOCAL="$BIN_DIR/agent-deck-local"
OFFICIAL="$BIN_DIR/agent-deck-official"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

current_target() {
    if [[ -L "$LINK" ]]; then
        readlink "$LINK" | xargs basename
    else
        echo "none"
    fi
}

show_status() {
    local current
    current=$(current_target)

    echo ""
    echo -e "${CYAN}agent-deck version switcher${NC}"
    echo "─────────────────────────────────────"

    if [[ -f "$LOCAL" ]]; then
        local local_ver
        local_ver=$("$LOCAL" version 2>&1 || echo "unknown")
        if [[ "$current" == "agent-deck-local" ]]; then
            echo -e "  ${GREEN}● local${NC}    $local_ver  ${GREEN}(active)${NC}"
        else
            echo -e "  ○ local    $local_ver"
        fi
    else
        echo -e "  ${RED}✗ local    not installed${NC}"
    fi

    if [[ -f "$OFFICIAL" ]]; then
        local official_ver
        official_ver=$("$OFFICIAL" version 2>&1 || echo "unknown")
        if [[ "$current" == "agent-deck-official" ]]; then
            echo -e "  ${GREEN}● official${NC} $official_ver  ${GREEN}(active)${NC}"
        else
            echo -e "  ○ official $official_ver"
        fi
    else
        echo -e "  ${RED}✗ official not installed${NC}"
    fi

    echo "─────────────────────────────────────"
    echo ""
}

switch_to() {
    local target_name="$1"
    local target_path="$BIN_DIR/agent-deck-$target_name"

    if [[ ! -f "$target_path" ]]; then
        echo -e "${RED}Error: agent-deck-$target_name not found${NC}"
        exit 1
    fi

    rm -f "$LINK"
    ln -s "$target_path" "$LINK"
    local ver
    ver=$("$LINK" version 2>&1 || echo "unknown")
    echo -e "${GREEN}Switched to $target_name${NC} ($ver)"
}

case "${1:-}" in
    local)
        switch_to "local"
        ;;
    official)
        switch_to "official"
        ;;
    status|"")
        show_status
        if [[ -z "${1:-}" ]]; then
            # Interactive toggle
            current=$(current_target)
            if [[ "$current" == "agent-deck-local" ]]; then
                echo -e "Toggle to ${YELLOW}official${NC}? [y/N] "
                read -r -n 1 reply
                echo
                [[ "$reply" =~ ^[Yy]$ ]] && switch_to "official"
            elif [[ "$current" == "agent-deck-official" ]]; then
                echo -e "Toggle to ${YELLOW}local${NC}? [y/N] "
                read -r -n 1 reply
                echo
                [[ "$reply" =~ ^[Yy]$ ]] && switch_to "local"
            fi
        fi
        ;;
    *)
        echo "Usage: agent-deck-switch [local|official|status]"
        exit 1
        ;;
esac
