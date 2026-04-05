#!/usr/bin/env bash
# =============================================================================
# cleanup-agents.sh — Remove disconnected/stale Wazuh agents
# Run on the Ubuntu Server (Wazuh Manager)
# Usage: sudo bash cleanup-agents.sh
# =============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "[$(date +%T)] $1"; }
ok()   { log "${GREEN}[OK]${NC}   $1"; }
info() { log "${YELLOW}[INFO]${NC} $1"; }
err()  { log "${RED}[ERR]${NC}  $1"; }

if [[ $EUID -ne 0 ]]; then
  err "Run as root: sudo bash cleanup-agents.sh"
  exit 1
fi

AGENT_CONTROL="/var/ossec/bin/agent_control"
MANAGE_AGENTS="/var/ossec/bin/manage_agents"

info "Listing all agents..."
$AGENT_CONTROL -l

echo ""
read -rp "Remove all DISCONNECTED agents? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
  info "Aborted."
  exit 0
fi

# Get IDs of disconnected agents (status D)
DISCONNECTED=$($AGENT_CONTROL -l | awk '/Disconnected/ {print $2}' | tr -d ',')

if [[ -z "$DISCONNECTED" ]]; then
  ok "No disconnected agents found."
  exit 0
fi

for agent_id in $DISCONNECTED; do
  info "Removing agent ID: ${agent_id}"
  echo "y" | $MANAGE_AGENTS -r "$agent_id" 2>/dev/null && ok "Removed agent ${agent_id}" || err "Failed to remove agent ${agent_id}"
done

info "Restarting Wazuh manager to apply changes..."
systemctl restart wazuh-manager

ok "Cleanup complete. Remaining agents:"
$AGENT_CONTROL -l
