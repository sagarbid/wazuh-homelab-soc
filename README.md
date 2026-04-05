# 🛡️ SOC Analyst Portfolio: Wazuh Homelab (Active Agent + Alerts)

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen?style=flat-square&logo=github-actions)](https://github.com/sagarbid/wazuh-homelab-soc/actions)
[![Deploy](https://img.shields.io/badge/deploy-GitHub%20Pages-blue?style=flat-square&logo=github)](https://sagarbid.github.io/wazuh-homelab-soc)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Wazuh](https://img.shields.io/badge/Wazuh-4.x-blue?style=flat-square&logo=wazuh)](https://wazuh.com)
[![Platform](https://img.shields.io/badge/platform-VMware%20Workstation-607078?style=flat-square&logo=vmware)](https://www.vmware.com)
[![Security+](https://img.shields.io/badge/aligned-CompTIA%20Security%2B-red?style=flat-square)](https://www.comptia.org/certifications/security)

> A fully functional, hands-on Security Operations Centre (SOC) simulation built in a local VMware homelab. Demonstrates real-world SIEM capabilities: agent deployment, log ingestion, rule-based alerting, and MITRE ATT&CK mapping — directly applicable to **Melbourne IT security roles**.

---

## 📋 Executive Summary

This project provisions a complete Wazuh SIEM stack across two virtual machines connected via a NAT network, with a Kali Linux agent actively reporting security events to an Ubuntu Server manager. The lab simulates attack telemetry (port scans, login attempts) and demonstrates SOC analyst workflows: triage, investigation, and alert management.

**Why this matters for Melbourne SOC roles:**
- Hands-on SIEM administration (not just certification theory)
- Demonstrates log analysis, event correlation, and MITRE ATT&CK alignment
- Mirrors enterprise SOC tooling used by Telstra, ANZ, CBA, and Victorian Government agencies

---

## 🏗️ Architecture

```mermaid
graph TB
    subgraph VMware["VMware Workstation — NAT Network (192.168.x.0/24)"]
        direction TB
        UBUNTU["🖥️ Ubuntu Server 22.04\nWazuh Manager + Indexer + Dashboard\nIP: 192.168.x.10"]
        KALI["🐧 Kali Linux 2024\nWazuh Agent\nIP: 192.168.x.20"]
        UBUNTU <-->|"ossec-authd (1515)\nossec-remoted (1514)\nWazuh API (55000)"| KALI
    end
    BROWSER["🌐 Browser\nWazuh Dashboard :443"] --> UBUNTU
    ANALYST["👤 SOC Analyst"] --> BROWSER
```

### Network Topology

![NAT Network Topology](diagrams/wazuh_nat_topology.png)

---

## ⚡ Quick Start

> Prerequisites: VMware Workstation Pro/Player, 8GB+ RAM, 60GB+ disk. See [01-prerequisites.md](docs/01-prerequisites.md).

### Step-by-Step Build

**1. Provision Ubuntu Server Manager VM**
```bash
# Minimum specs: 4 vCPU, 4GB RAM, 50GB disk
# OS: Ubuntu Server 22.04 LTS
```
Follow [02-ubuntu-manager.md](docs/02-ubuntu-manager.md)

**2. Install Wazuh All-in-One**
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
sudo bash wazuh-install.sh -a
```

**3. Provision Kali Linux Agent VM**
```bash
# Minimum specs: 2 vCPU, 2GB RAM, 30GB disk
# OS: Kali Linux 2024.x
```
Follow [03-kali-agent.md](docs/03-kali-agent.md)

**4. Register and Enrol the Agent**
```bash
# On Kali — enrol agent (replace MANAGER_IP)
sudo /var/ossec/bin/agent-auth -m 192.168.x.10
sudo systemctl restart wazuh-agent
```

**5. Simulate Attacks and Trigger Alerts**
```bash
# Run the test script from Kali
sudo bash scripts/test-attacks.sh
```
Follow [04-test-alerts.md](docs/04-test-alerts.md)

**6. Access Wazuh Dashboard**
```
https://<MANAGER_IP>
Username: admin
Password: <generated during install — see wazuh-passwords.txt>
```

---

## 📸 Screenshots Gallery

### Installation & Setup

| VMware Installed | Wazuh Install Complete |
|---|---|
| ![VMware](screenshots/install/VMware%20Installed.png) | ![Wazuh Dashboard Login](screenshots/install/Wazuh%20Dashboard%20Admin%20and%20Password.png) |

| Wazuh Dashboard | Two VMs Side by Side |
|---|---|
| ![Dashboard](screenshots/install/Wazuh%20Dashboard.png) | ![Two VMs](screenshots/install/Two%20VMs%20Side%20by%20Side.png) |

### Agent Deployment

| Wazuh Agent Installed on Kali | Kali Agent Active in Wazuh |
|---|---|
| ![Install](screenshots/agents/Installed%20Wazuh%20Agent%20on%20Kali.png) | ![Active](screenshots/agents/Kali%20Agent%20Active%20in%20Wazuh.png) |

| Enrolled Kali Agent |
|---|
| ![Enrolled](screenshots/agents/Enrolled%20Kali%20Agent.png) |

### Security Alerts

| Security Events | MITRE ATT&CK Dashboard |
|---|---|
| ![Events](screenshots/alerts/Security%20Events.png) | ![MITRE](screenshots/alerts/MITRE%20Attack%20Dashboard.png) |

| Security Events Exported |
|---|
| ![Exported](screenshots/alerts/Security%20Events%20Exported.png) |

### Network

| NAT Network Config | Ubuntu IP | Kali IP | Wazuh Server IP |
|---|---|---|---|
| ![NAT](screenshots/network/NAT%20network%20Config.png) | ![Ubuntu](screenshots/network/Ubuntu%20ip%20a%20and%20ping%20output.png) | ![Kali](screenshots/network/Kali%20Linux%20ip%20a%20and%20ping%20output.png) | ![Server](screenshots/network/Wazuh%20Server%20IP.png) |

---

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|---|---|---|
| **SIEM Manager** | Wazuh 4.x | Log collection, analysis, alerting |
| **Search Engine** | OpenSearch (built-in) | Event indexing and querying |
| **Dashboard** | Wazuh Dashboard (Kibana fork) | Visualisation, MITRE ATT&CK mapping |
| **Agent OS** | Kali Linux 2024 | Simulated endpoint / attack source |
| **Manager OS** | Ubuntu Server 22.04 LTS | Wazuh backend host |
| **Hypervisor** | VMware Workstation | VM orchestration |
| **Network** | VMware NAT | Isolated lab network |
| **CI/CD** | GitHub Actions | Docs deployment to GitHub Pages |

---

## 🎯 SOC Skills Demonstrated

- **Log Management** — Centralised syslog and ossec log ingestion from multiple OS types
- **Alert Triage** — Rule-based alerting with severity classification (level 3–15)
- **Threat Detection** — Port scan detection, brute-force identification, file integrity monitoring
- **MITRE ATT&CK** — Event correlation mapped to T-codes (e.g., T1046 Network Service Discovery)
- **Agent Lifecycle** — Full agent enrolment, registration, and health monitoring
- **Rule Customisation** — Custom `local_rules.xml` for organisation-specific detections
- **Incident Evidence** — Alert export and evidence packaging for escalation

---

## 🇦🇺 Melbourne SOC Job Relevance

This homelab directly mirrors tooling and workflows evaluated in Melbourne's security hiring market:

| Employer Sector | Relevant Skill Demonstrated |
|---|---|
| Big 4 Banks (ANZ, CBA, NAB, Westpac) | SIEM alert triage, log analysis, incident documentation |
| Telco (Telstra, Optus) | Agent deployment at scale, rule customisation |
| Victorian Government (DPC, Service Victoria) | ASD Essential 8 aligned controls, audit logging |
| Managed Security Providers (Tesserent, CyberCX) | Multi-tenant agent management, custom detection rules |

**Certifications aligned:** CompTIA Security+, CySA+, AZ-500, SC-200 (Microsoft Sentinel concepts transferable)

---

## 📁 Repository Structure

```
wazuh-homelab-soc/
├── README.md                    # This file
├── docs/
│   ├── 01-prerequisites.md      # Hardware, software requirements
│   ├── 02-ubuntu-manager.md     # Manager VM setup guide
│   ├── 03-kali-agent.md         # Agent VM setup guide
│   ├── 04-test-alerts.md        # Attack simulation & alert verification
│   └── 05-troubleshooting.md    # Common errors and fixes
├── screenshots/
│   ├── install/                 # VMware, dashboard setup
│   ├── agents/                  # Agent control, enrolment
│   ├── alerts/                  # Security events, MITRE dashboard
│   └── network/                 # NAT config, IP addresses
├── configs/
│   ├── ubuntu-config.yml        # Wazuh manager config reference
│   └── kali-ossec.conf          # Agent ossec.conf reference
├── diagrams/
│   └── wazuh_nat_topology.png   # Network diagram
├── scripts/
│   ├── test-attacks.sh          # Attack simulation script
│   └── cleanup-agents.sh        # Agent cleanup utility
└── .github/workflows/
    └── cd.yml                   # GitHub Pages deployment
```

---

## 🚀 Open in GitHub Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/sagarbid/wazuh-homelab-soc)

> **Note:** Codespaces opens the docs and scripts for review. The Wazuh stack requires VMware and cannot run inside Codespaces — use this for documentation browsing and script review only.

---

## 📄 License

MIT © 2025 Sagar Bidari — see [LICENSE](LICENSE)

---

*Built with 🛡️ as part of an active SOC Analyst job search in Melbourne, Australia.*
