# 04 — Attack Simulation & Alert Testing

## Overview

This section walks through generating security events from the Kali agent to verify Wazuh is detecting and alerting correctly. All tests are run **within the isolated NAT lab** — no external systems are targeted.

---

## 1. Run the Test Script

```bash
# From Kali Linux
sudo bash /path/to/scripts/test-attacks.sh
```

Or run individual tests manually as described below.

---

## 2. Port Scan (Nmap)

Simulates **T1046 — Network Service Discovery** in MITRE ATT&CK.

```bash
# From Kali — scan the Wazuh Manager
nmap -sV -p 22,443,1514,1515,55000 <MANAGER_IP>

# Full TCP scan (generates more alerts)
sudo nmap -sS -T4 <MANAGER_IP>
```

**Expected Wazuh alert:** Rule 533 or similar — "Nmap scan detected" (level 6+)

---

## 3. SSH Brute Force Simulation

Simulates **T1110 — Brute Force**.

```bash
# Generate failed SSH logins (uses hydra)
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://<MANAGER_IP> -t 4 -V 2>&1 | head -20

# Simpler alternative — manual failed logins
for i in {1..10}; do ssh baduser@<MANAGER_IP> -o StrictHostKeyChecking=no 2>/dev/null; done
```

**Expected Wazuh alert:** Rule 5763 — "Multiple failed SSH logins" (level 10)

---

## 4. Netcat Listener Test

Verifies agent-manager communication.

```bash
# From Kali — test UDP port 514 (syslog)
echo "Test syslog message from Kali" | nc -u <MANAGER_IP> 514
```

---

## 5. File Integrity Monitoring (FIM) Test

Wazuh monitors `/etc`, `/bin`, `/usr` by default.

```bash
# Create a file in a monitored directory
sudo touch /etc/wazuh-fim-test.txt
echo "test content" | sudo tee /etc/wazuh-fim-test.txt

# Modify it
echo "modified" | sudo tee -a /etc/wazuh-fim-test.txt

# Delete it
sudo rm /etc/wazuh-fim-test.txt
```

**Expected Wazuh alerts:** Rules 554, 550, 553 — file added, modified, deleted (level 7)

---

## 6. Verify Alerts in Dashboard

1. Navigate to `https://<MANAGER_IP>`
2. Go to **Security Events** in the left sidebar
3. Filter by **Agent = Kali-Agent**
4. You should see events from the above tests

### MITRE ATT&CK View

1. Go to **Threat Intelligence → MITRE ATT&CK**
2. Observe T1046 (port scan), T1110 (brute force) mapped to the detected events

---

## 7. Export Alerts

```bash
# Export last 100 alerts from the manager
sudo tail -n 100 /var/ossec/logs/alerts/alerts.json | python3 -m json.tool > ~/exported-alerts.json
```

Or from the Dashboard: **Security Events → Export** (CSV or JSON).

---

## 8. Custom Rule Test

Add a custom rule to detect a specific keyword in logs:

```xml
<!-- In /var/ossec/etc/rules/local_rules.xml on Ubuntu Manager -->
<group name="custom_soc_lab,">
  <rule id="100001" level="10">
    <match>SOC_LAB_TEST</match>
    <description>Custom SOC lab test event detected</description>
  </rule>
</group>
```

```bash
# Reload rules on manager
sudo systemctl restart wazuh-manager

# Trigger on Kali
logger "SOC_LAB_TEST triggered from Kali"
```

---

Next: [05 — Troubleshooting →](05-troubleshooting.md)
