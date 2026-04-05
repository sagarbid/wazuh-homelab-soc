# 05 — Troubleshooting

## Agent Issues

### Agent shows "Never Connected" or "Disconnected"

**Symptom:** Agent appears in the dashboard but status is red/disconnected.

**Diagnosis:**
```bash
# On Kali — check agent log for errors
sudo tail -50 /var/ossec/logs/ossec.log

# On Ubuntu — check manager sees the connection attempt
sudo tail -50 /var/ossec/logs/ossec.log | grep -i "error\|agent\|disconnected"
```

**Fix 1 — Firewall blocking port 1514:**
```bash
# On Ubuntu Manager
sudo ufw allow 1514/udp
sudo ufw allow 1515/tcp
sudo ufw reload
```

**Fix 2 — Wrong Manager IP configured:**
```bash
# On Kali — check configured manager IP
sudo cat /var/ossec/etc/ossec.conf | grep server-ip

# Update if wrong
sudo sed -i 's/<server-ip>.*<\/server-ip>/<server-ip>CORRECT_IP<\/server-ip>/' /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-agent
```

**Fix 3 — Agent not re-registered after manager reinstall:**
```bash
# On Ubuntu — remove old agent entry
sudo /var/ossec/bin/manage_agents -r <AGENT_ID>

# Re-register on Kali
sudo /var/ossec/bin/agent-auth -m <MANAGER_IP>
sudo systemctl restart wazuh-agent
```

---

## Dashboard Issues

### Dashboard not loading (timeout or SSL error)

**Diagnosis:**
```bash
# On Ubuntu — check dashboard service
sudo systemctl status wazuh-dashboard
sudo journalctl -u wazuh-dashboard -n 30
```

**Fix 1 — Service crashed, restart it:**
```bash
sudo systemctl restart wazuh-dashboard
```

**Fix 2 — Indexer not running (dashboard depends on it):**
```bash
sudo systemctl status wazuh-indexer
sudo systemctl start wazuh-indexer
sudo systemctl restart wazuh-dashboard
```

**Fix 3 — Memory exhausted (common on 4GB RAM):**
```bash
free -h
# If very low, reboot the Ubuntu VM
sudo reboot
```

---

## Installation Issues

### `wazuh-install.sh` fails midway

**Symptom:** Script exits with an error during indexer configuration.

**Fix — Clean and retry:**
```bash
sudo bash wazuh-install.sh -u   # uninstall
sudo bash wazuh-install.sh -a   # reinstall
```

### Certificate errors on dashboard

```bash
# Regenerate certificates
cd /etc/wazuh-indexer/certs
sudo /usr/share/wazuh-indexer/bin/wazuh-certs-tool.sh --dashboard
sudo systemctl restart wazuh-dashboard
```

---

## Network Issues

### VMs cannot ping each other

**Check 1 — Both VMs on NAT (not Bridged):**
- VMware → VM Settings → Network Adapter → **NAT**

**Check 2 — VMware NAT service running (Windows host):**
- Services → `VMware NAT Service` → Start

**Check 3 — Firewall blocking ICMP:**
```bash
# On Ubuntu — temporarily allow all (for testing only)
sudo ufw disable
ping <KALI_IP>
sudo ufw enable
```

---

## Log Locations Reference

| Component | Log Path |
|---|---|
| Wazuh Manager | `/var/ossec/logs/ossec.log` |
| Wazuh Alerts | `/var/ossec/logs/alerts/alerts.json` |
| Wazuh Agent (Kali) | `/var/ossec/logs/ossec.log` |
| Wazuh Dashboard | `journalctl -u wazuh-dashboard` |
| Wazuh Indexer | `journalctl -u wazuh-indexer` |

---

## Useful Commands Reference

```bash
# Manager — list all agents
sudo /var/ossec/bin/agent_control -l

# Manager — restart all components
sudo systemctl restart wazuh-manager wazuh-indexer wazuh-dashboard

# Agent — check connection status
sudo /var/ossec/bin/agent_control -i <AGENT_ID>

# Agent — test config syntax
sudo /var/ossec/bin/wazuh-logtest

# View real-time alerts
sudo tail -f /var/ossec/logs/alerts/alerts.json | python3 -m json.tool
```

---

*Still stuck? Open an issue on the [GitHub repo](https://github.com/sagarbid/wazuh-homelab-soc/issues).*
