# **RRZT** - MediaStack

[![Mit License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge&logo=mit&logoColor=white)](https://github.com/rrzt-it/mediastack/blob/main/LICENSE) [![gitlab](https://img.shields.io/badge/GitLab-RRZT-black?style=for-the-badge&logo=gitlab&logoColor=white)](https://gitlab.com/rrzt-it/mediastack)

> Zero-Touch Deployment Engine

Contains the declarative infrastructure and orchestration scripts for Rzzt It is a 100% automated, zero-touch media acquisition, processing, and telemetry environment built on Docker Compose and managed via PowerShell orchestrators.

---

<p align="center">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white" />
  
  <br>

  <img src="https://img.shields.io/badge/Traefik-24A1C1?style=for-the-badge&logo=traefik&logoColor=white" />
  <img src="https://img.shields.io/badge/AdGuard_Home-68BC71?style=for-the-badge&logo=adguard&logoColor=white" />
  <img src="https://img.shields.io/badge/WireGuard_(Gluetun)-881798?style=for-the-badge&logo=wireguard&logoColor=white" />
  
  <br>

  <img src="https://img.shields.io/badge/Plex-E5A00D?style=for-the-badge&logo=plex&logoColor=white" />
  <img src="https://img.shields.io/badge/Jellyfin-00A4DC?style=for-the-badge&logo=jellyfin&logoColor=white" />
  <img src="https://img.shields.io/badge/Emby-52B54B?style=for-the-badge&logo=emby&logoColor=white" />
  
  <br>

  <img src="https://img.shields.io/badge/Prowlarr-FFC230?style=for-the-badge&logoColor=black" />
  <img src="https://img.shields.io/badge/Radarr-FFC230?style=for-the-badge&logo=radarr&logoColor=black" />
  <img src="https://img.shields.io/badge/Sonarr-89C3EB?style=for-the-badge&logo=sonarr&logoColor=black" />
  <img src="https://img.shields.io/badge/Lidarr-00A4DC?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Readarr-E5A00D?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Bazarr-881798?style=for-the-badge&logoColor=white" />
  
  <br>

  <img src="https://img.shields.io/badge/qBittorrent-2D72B8?style=for-the-badge&logo=qbittorrent&logoColor=white" />
  <img src="https://img.shields.io/badge/FileFlows-2496ED?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Unpackerr-68BC71?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Seerr-E6522C?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/FlareSolverr-F38020?style=for-the-badge&logo=cloudflare&logoColor=white" />
  <img src="https://img.shields.io/badge/Recyclarr-2D72B8?style=for-the-badge&logoColor=white" />
  
  <br>

  <img src="https://img.shields.io/badge/Homepage-24A1C1?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Tautulli-121111?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
  <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
  <img src="https://img.shields.io/badge/cAdvisor-2496ED?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Dozzle-FFC230?style=for-the-badge&logoColor=black" />
  <img src="https://img.shields.io/badge/Watchtower-5391FE?style=for-the-badge&logoColor=white" />
</p>

---

## 1. **Architecture Overview**

■ **Edge Routing**: Traefik (Auto-discovery, Let's Encrypt TLS).
■ **Privacy & DNS**: Gluetun (Wireguard killswitch) and AdGuard Home (Split-horizon DNS).
■ **Acquisition Suite**: Prowlarr, Radarr, Sonarr, Lidarr, Readarr, Bazarr.
■ **Companions**: FlareSolverr (Cloudflare bypass), Unpackerr (Automated extraction).
■ **Processing**: FileFlows (Node-based media transcoding).
■ **Playback & Requests**: Plex, Jellyfin, Emby (Deployed via Compose Profiles), Seerr.
■ **Telemetry & Logs**: Grafana (cAdvisor/Prometheus), Tautulli, Dozzle, Homepage.

---

## 2. **Repository Structure**

Clone this repository to `/opt/mediastack` on your target Docker host. The infrastructure relies on this exact directory tree.

```text
/opt/mediastack/
├── .env                          # Environment variables and dynamic API keys
├── docker-compose.yml            # Base declarative infrastructure
├── libraries.json                # Single source of truth for storage arrays
├── deploy.ps1                    # Primary TUI deployment orchestrator
├── verify.ps1                    # Pre-flight syntax and dependency validation
├── init-stack.sh                 # Internal API configuration payload
├── backup-stack.sh               # Atomic tar/rsync disaster recovery
├── Set-MediaVolumes.ps1          # Dynamic YAML override generator
├── Test-ContainerPaths.ps1       # Filesystem access validation
└── config/
    ├── traefik/acme.json
    ├── prometheus/prometheus.yml
    ├── grafana/provisioning/
    ├── recyclarr/recyclarr.yml
    └── homepage/
```

---

## 3. **Host System Prerequisites**

### 3.1. OS & Packages
The host must run a standard Linux distribution with Docker Engine, Docker Compose plugin, and PowerShell Core (`pwsh`) installed.

### 3.2. Hardware Acceleration (GPU)
To utilize hardware transcoding in Plex, Jellyfin, Emby, or FileFlows, install the corresponding host drivers:
◆ **Intel/AMD**: `intel-media-va-driver-non-free` or `mesa-va-drivers`. The stack maps `/dev/dri` natively.
◆ **NVIDIA**: Install the `nvidia-container-toolkit` and uncomment the `deploy.resources.reservations.devices` blocks in `docker-compose.yml`.

### 3.3. Log Rotation
Prevent Docker from consuming all host inodes. Create `/etc/docker/daemon.json` and restart the Docker daemon:
```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3", "compress": "true" }
}
```

---

## 4. **Configuration**

Do not manually edit the `docker-compose.yml` file to add storage paths. Storage is managed entirely via JSON abstraction.

### Step 1: Define Environment Variables
Edit `/opt/mediastack/.env`. Provide your domain, Wireguard keys, and internal IP. **Leave all `_API_KEY` variables blank.**

### *Step 2: Define Storage Arrays*
Edit `/opt/mediastack/libraries.json`. Map your physical host disks to their target categories. The orchestrator will dynamically generate the `docker-compose.override.yml` at deployment.

```json
[
  {
    "Tags": ["radarr", "bazarr", "plex", "fileflows"],
    "Source": "/mnt/disk1/movies",
    "Target": "/data/media/movies",
    "Category": "movies"
  }
]
```

---

## 5. **Deployment Pipeline**

Execution of the stack is handled entirely by the PowerShell orchestrators. Do not use raw `docker compose` commands for initial deployment.

### Phase 1: Pre-Flight Validation
Execute the verification script to ensure all JSON/YAML syntax is valid and required configuration directories exist.
```bash
pwsh /opt/mediastack/verify.ps1
```

### Phase 2: Zero-Touch Deployment
Execute the deployment orchestrator. This script compiles the volumes, boots the stack, waits for API readiness, injects the routing payloads, extracts the API keys, and validates the storage mounts.
```bash
pwsh /opt/mediastack/deploy.ps1
```

### Phase 3: Split-Horizon DNS (Post-Deploy)
Access AdGuard Home at port `3000` to complete the setup wizard. Set the web interface to port `80`. Apply the internal DNS rewrite rule to bypass hairpin NAT:
```bash
curl -X POST http://<HOST_IP>/control/rewrite/add \
  -H "Authorization: Basic <base64_admin:password>" \
  -H "Content-Type: application/json" \
  -d '{"domain":"*.yourdomain.com","answer":"<HOST_IP>"}'
```

---

## 6. **Operations & Telemetry**

Access the infrastructure via your defined `DOMAIN_NAME` (e.g., `https://home.yourdomain.com`). 

■ **Application Logs**: `https://logs.yourdomain.com` (Dozzle multiplexes STDOUT/STDERR directly from the Docker socket).
■ **Resource Metrics**: `https://grafana.yourdomain.com` (Pre-provisioned with cAdvisor dashboards enforcing CPU/Memory limits).
■ **Disaster Recovery**: A cron job should be configured to execute `/opt/mediastack/backup-stack.sh` daily at `03:00`. This script freezes container I/O to safely archive SQLite databases without WAL corruption.

---

## **Detailed API Reference: docs**

This repository relies on direct API manipulation to enforce Configuration as Code. Maintainers should reference these execution paths when modifying the stack.

### 1. Pre-Deployment Configuration Merging (Docker CLI)
When `deploy.ps1` executes `Set-MediaVolumes.ps1`, it generates `docker-compose.override.yml`. The Docker Engine API (`POST /v1.43/containers/create`) natively intercepts this override file. It recursively merges dictionaries (like `environment` labels) but strictly **concatenates lists** (like `volumes`). This guarantees the base `/config` mounts are never overwritten by the dynamic storage overrides.

### 2. Zero-Touch Bootstrapping (`init-stack.sh`)
The orchestrator avoids host-level dependencies (like `jq`) by executing JSON parsing natively via Python 3, which is piped into standard bash functions. 
● **Idempotency**: Every `POST` request sent to a container's REST API is preceded by a `GET` request to verify the state. This ensures `deploy.ps1` can be run infinitely without duplicating download clients or indexer proxies in the *Arr databases.
● **Key Extraction**: Exec instances (`POST /containers/{id}/exec`) are spawned inside the Alpine containers using `sed` and `awk` to extract generated API keys from XML and INI files directly into host memory, bypassing the need for manual UI retrieval.

### 3. TUI Rendering Engine (`deploy.ps1` / `verify.ps1`)
The PowerShell scripts utilize strict ANSI 256-color escape sequences (`\e[38;5;Nm`). To prevent terminal grid tearing across different Linux emulator widths, padding length calculations (`$TargetWidth - $ConstructedString.Length`) are performed against the raw text payload **before** the ANSI color bytes are encapsulated around the string.


# **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.