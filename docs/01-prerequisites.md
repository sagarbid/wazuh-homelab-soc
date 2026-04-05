# 01 — Prerequisites

## Host Machine Requirements

| Resource | Minimum | Recommended |
|---|---|---|
| CPU | 4 cores (with VT-x/AMD-V) | 8 cores |
| RAM | 8 GB | 16 GB |
| Disk | 100 GB free | 200 GB SSD |
| OS | Windows 10/11 or Linux | Windows 11 |

> **Enable virtualisation in BIOS/UEFI before proceeding.** Look for Intel VT-x or AMD-V in your firmware settings.

---

## Software Downloads

### 1. VMware Workstation Pro / Player

- **Download:** https://www.vmware.com/products/workstation-pro.html
- VMware Workstation **Pro is now free** for personal use (as of May 2024)
- Version used in this lab: VMware Workstation 17

### 2. Ubuntu Server 22.04 LTS ISO

```
https://ubuntu.com/download/server
```
- File: `ubuntu-22.04.x-live-server-amd64.iso`
- SHA256 verify after download

### 3. Kali Linux 2024.x ISO

```
https://www.kali.org/get-kali/#kali-installer-images
```
- File: `kali-linux-2024.x-installer-amd64.iso`
- Use the **Installer** image (not live)

---

## Network Planning

This lab uses a **VMware NAT network** so both VMs share internet access through the host while being isolated from the physical LAN.

| VM | Role | Suggested IP |
|---|---|---|
| Ubuntu Server | Wazuh Manager | 192.168.x.10 (DHCP or static) |
| Kali Linux | Wazuh Agent | 192.168.x.20 (DHCP or static) |

> Note the exact subnet assigned by VMware: open **Edit → Virtual Network Editor** → look for VMnet8 (NAT) subnet.

---

## Knowledge Prerequisites

- Basic Linux command line (cd, sudo, systemctl, cat)
- Understanding of IP networking (subnets, ping, ports)
- Familiarity with SIEM concepts is helpful but not required

---

## Time Estimate

| Phase | Duration |
|---|---|
| VM provisioning (both) | ~45 min |
| Wazuh install on Ubuntu | ~20 min |
| Agent install on Kali | ~10 min |
| Alert testing and verification | ~20 min |
| **Total** | **~95 min** |

---

Next: [02 — Ubuntu Manager Setup →](02-ubuntu-manager.md)
