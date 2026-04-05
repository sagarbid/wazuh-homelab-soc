# 03 — Kali Linux Agent Setup

## 1. Create the Kali VM in VMware

1. Open VMware Workstation → **Create a New Virtual Machine**
2. Select **Typical** → Next
3. Installer ISO: browse to `kali-linux-2024.x-installer-amd64.iso`
4. Configure:
   - **Name:** `Kali-Agent`
   - **CPUs:** 2 processors, 1 core each
   - **RAM:** 2048 MB (2 GB)
   - **Disk:** 30 GB
5. **Network Adapter:** Set to **NAT** (same as Ubuntu)
6. Finish → Power On

---

## 2. Install Kali Linux

1. Select **Graphical Install**
2. Language → English, Location → Australia, Keyboard → American English
3. Hostname: `kali-agent`
4. User: `kali` / set password
5. Partition: **Guided — use entire disk**
6. Software: leave defaults (Kali desktop + tools)
7. Install GRUB → `/dev/sda`
8. Reboot

---

## 3. Post-Install Network Check

```bash
# Check Kali's IP
ip a

# Confirm connectivity to the Wazuh Manager
ping -c 3 <MANAGER_IP>

# Confirm Wazuh ports are reachable
nc -zv <MANAGER_IP> 1514
nc -zv <MANAGER_IP> 1515
```

Both `nc` checks must show **succeeded** — if not, check VMware NAT settings and Ubuntu firewall (`sudo ufw status`).

---

## 4. Install the Wazuh Agent

```bash
# Add Wazuh GPG key and repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --dearmor -o /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | \
  sudo tee /etc/apt/sources.list.d/wazuh.list

sudo apt update

# Install agent (replace MANAGER_IP with actual IP)
sudo WAZUH_MANAGER='<MANAGER_IP>' apt install -y wazuh-agent
```

---

## 5. Enrol the Agent

```bash
# Register with the manager (uses port 1515)
sudo /var/ossec/bin/agent-auth -m <MANAGER_IP>

# Start and enable the agent service
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

# Verify it's running
sudo systemctl status wazuh-agent
```

Expected: `Active: active (running)`

---

## 6. Confirm Enrolment on the Manager

On the Ubuntu VM:

```bash
sudo /var/ossec/bin/agent_control -l
```

You should see your Kali agent listed with status `Active`.

On the Wazuh Dashboard: navigate to **Agents** → the Kali agent should appear as **Active** (green).

---

## 7. Troubleshooting Agent Connection

**Agent shows "Disconnected":**
```bash
# On Kali — check agent logs
sudo tail -f /var/ossec/logs/ossec.log

# On Ubuntu — check manager logs
sudo tail -f /var/ossec/logs/ossec.log | grep "agent"
```

**Registration fails (connection refused on 1515):**
```bash
# On Ubuntu — ensure authd is running
sudo /var/ossec/bin/wazuh-authd -p 1515
# Or check if already listening:
sudo ss -tlnp | grep 1515
```

---

Next: [04 — Test Alerts →](04-test-alerts.md)
