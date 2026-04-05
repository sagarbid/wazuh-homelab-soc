# 02 — Ubuntu Server Manager Setup

## 1. Create the Ubuntu VM in VMware

1. Open VMware Workstation → **Create a New Virtual Machine**
2. Select **Typical (recommended)** → Next
3. Installer disc image file (iso): browse to `ubuntu-22.04.x-live-server-amd64.iso`
4. Configure:
   - **Name:** `Wazuh-Manager`
   - **CPUs:** 2 processors, 2 cores each (4 total)
   - **RAM:** 4096 MB (4 GB)
   - **Disk:** 50 GB, Store as single file
5. **Network Adapter:** Set to **NAT**
6. Finish → Power On

---

## 2. Install Ubuntu Server

1. Select **Install Ubuntu Server**
2. Choose language → English
3. Network: DHCP is fine (note the assigned IP — you'll need it)
4. Storage: **Use entire disk** (guided)
5. Profile setup:
   - Name: `wazuh`
   - Username: `wazuh`
   - Password: set a strong password
6. **OpenSSH server:** ✅ Install
7. No snaps needed → Done
8. Reboot when prompted, remove ISO

---

## 3. Post-Install Checks

```bash
# Log in, then confirm network
ip a
ping -c 3 8.8.8.8

# Update system
sudo apt update && sudo apt upgrade -y
```

Note the IP address shown by `ip a` on the `ens33` (or similar) interface — this is your **MANAGER_IP**.

---

## 4. Install Wazuh (All-in-One)

The all-in-one installer deploys Wazuh Manager, Indexer, and Dashboard on a single VM — ideal for homelab.

```bash
# Download the installer
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh

# Run (takes 10-15 minutes)
sudo bash wazuh-install.sh -a

# Save the generated credentials — displayed at end of install
# Or extract later:
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

> **Common error:** `curl: (6) Could not resolve host` — check internet via `ping 8.8.8.8`. If ping works but curl fails, try `sudo systemctl restart systemd-resolved`.

---

## 5. Verify Services

```bash
# All three services must be active
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-indexer
sudo systemctl status wazuh-dashboard
```

Expected output for each: `Active: active (running)`

```bash
# Check manager is listening on agent port
sudo ss -tlnp | grep 1514
sudo ss -tlnp | grep 1515
```

---

## 6. Access the Dashboard

Open a browser on your host machine:

```
https://<MANAGER_IP>
```

- Accept the self-signed certificate warning
- Login: `admin` / `<password from install>`

You should see the Wazuh Dashboard with 0 agents — ready for enrolment.

---

## 7. (Optional) Set a Static IP

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.x.10/24
      gateway4: 192.168.x.2
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```bash
sudo netplan apply
```

---

Next: [03 — Kali Agent Setup →](03-kali-agent.md)
