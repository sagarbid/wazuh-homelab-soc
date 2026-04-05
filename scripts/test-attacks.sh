#!/usr/bin/env bash
# =============================================================================
# test-attacks.sh — Wazuh Homelab Attack Simulation Script
# Run from the Kali Linux agent VM (NOT on production systems)
# Usage: sudo bash test-attacks.sh <MANAGER_IP>
# =============================================================================

set -euo pipefail

MANAGER_IP="${1:-}"
LOGFILE="/tmp/wazuh-test-$(date +%Y%m%d_%H%M%S).log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

banner() {
  echo -e "${BLUE}"
  echo "=================================================="
  echo "  Wazuh Homelab SOC — Attack Simulation Script"
  echo "  Target: ${MANAGER_IP:-<not set>}"
  echo "  Log: ${LOGFILE}"
  echo "  WARNING: Run in isolated lab only!"
  echo "=================================================="
  echo -e "${NC}"
}

log() { echo -e "[$(date +%T)] $1" | tee -a "$LOGFILE"; }
ok()  { log "${GREEN}[PASS]${NC} $1"; }
info(){ log "${YELLOW}[INFO]${NC} $1"; }
err() { log "${RED}[FAIL]${NC} $1"; }

check_prereqs() {
  info "Checking prerequisites..."
  if [[ -z "$MANAGER_IP" ]]; then
    echo "Usage: sudo bash test-attacks.sh <MANAGER_IP>"
    exit 1
  fi

  if [[ $EUID -ne 0 ]]; then
    err "This script must be run as root (sudo)"
    exit 1
  fi

  for tool in nmap nc logger; do
    if ! command -v "$tool" &>/dev/null; then
      info "Installing $tool..."
      apt-get install -y "$tool" &>/dev/null
    fi
  done
  ok "Prerequisites met"
}

test_connectivity() {
  info "Testing connectivity to ${MANAGER_IP}..."
  if ping -c 2 -W 2 "$MANAGER_IP" &>/dev/null; then
    ok "Manager is reachable (ICMP)"
  else
    err "Cannot reach ${MANAGER_IP} — check network"
    exit 1
  fi

  if nc -zw 3 "$MANAGER_IP" 1514 2>/dev/null; then
    ok "Port 1514 (agent comms) is open"
  else
    err "Port 1514 not reachable — agent may not connect"
  fi
}

test_port_scan() {
  info "Test 1: Port Scan (MITRE T1046 — Network Service Discovery)"
  info "Running nmap against ${MANAGER_IP}..."

  nmap -sV -p 22,80,443,1514,1515,55000 "$MANAGER_IP" >> "$LOGFILE" 2>&1

  ok "Port scan complete — check Wazuh for Rule 533 (Nmap scan detected)"
  sleep 2
}

test_failed_ssh() {
  info "Test 2: SSH Failed Logins (MITRE T1110 — Brute Force)"
  info "Generating 5 failed SSH attempts..."

  for i in {1..5}; do
    ssh -o StrictHostKeyChecking=no \
        -o ConnectTimeout=3 \
        -o PasswordAuthentication=no \
        "nonexistentuser_soc_test@${MANAGER_IP}" 2>/dev/null || true
    sleep 0.5
  done

  ok "SSH attempts sent — check Wazuh for Rule 5763 (multiple failed logins)"
  sleep 2
}

test_fim() {
  info "Test 3: File Integrity Monitoring (MITRE T1565 — Data Manipulation)"
  local testfile="/etc/wazuh_soc_lab_test_$(date +%s).txt"

  info "Creating monitored file: ${testfile}"
  echo "SOC_LAB_TEST file created at $(date)" > "$testfile"
  sleep 1

  info "Modifying file..."
  echo "Modified at $(date)" >> "$testfile"
  sleep 1

  info "Deleting file..."
  rm -f "$testfile"

  ok "FIM test complete — check Wazuh for Rules 554/550/553 (file changes)"
  sleep 2
}

test_custom_rule() {
  info "Test 4: Custom Rule Trigger"
  info "Sending logger event with SOC_LAB_TEST keyword..."

  logger -t "wazuh-soc-test" "SOC_LAB_TEST: Custom rule test triggered from Kali at $(date)"

  ok "Custom event sent — check Wazuh for Rule 100001 if configured in local_rules.xml"
  sleep 1
}

test_netcat_probe() {
  info "Test 5: Network Probe (nc)"
  info "Probing common ports on ${MANAGER_IP}..."

  for port in 22 80 443 8080; do
    if nc -zw 2 "$MANAGER_IP" "$port" 2>/dev/null; then
      ok "Port $port is open on ${MANAGER_IP}"
    else
      info "Port $port is closed or filtered"
    fi
  done
}

summary() {
  echo ""
  echo -e "${GREEN}=================================================="
  echo "  All tests complete!"
  echo "  Log saved to: ${LOGFILE}"
  echo ""
  echo "  Next steps:"
  echo "  1. Open Wazuh Dashboard: https://${MANAGER_IP}"
  echo "  2. Go to Security Events → filter by this agent"
  echo "  3. Check Threat Intelligence → MITRE ATT&CK"
  echo "=================================================="
  echo -e "${NC}"
}

# ---- Main ----
banner
check_prereqs
test_connectivity
test_port_scan
test_failed_ssh
test_fim
test_custom_rule
test_netcat_probe
summary
