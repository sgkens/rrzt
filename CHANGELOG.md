# **Changelog**

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## **[1.1.0] - 2026-04-01**

### **Added**
🟦 Initial migration to GitLab with a standardized multi-branch workflow.  
🟦 **PowerShell Orchestration**: Zero-touch deployment engine (`deploy.ps1`) and manifest verification (`verify.ps1`).  
🟦 **Volume Management**: Automated Docker Compose override generator based on `libraries.json`.  
🟦 **Telemetry Suite**: Pre-configured Grafana dashboards, Prometheus, and cAdvisor.  
🟦 **Homepage Integration**: Declarative dashboard with API-backed service widgets.  
🟦 **Security First**: Clear warnings for default credentials and encrypted `.env` handling.  

### **Changed**
🟩 **API Logic**: Refactored `init-stack.sh` to resolve container hostnames via internal Docker networking.  
🟩 **Backups**: Standardized `backup-stack.sh` to utilize environment-sourced remote credentials.  
🟩 **Documentation**: Updated `README.md` to adhere to Senior Technical Writer formatting mandates.  

### **Fixed**
🟥 Resolved race conditions during API key extraction in the initialization pipeline.  

---

## **[1.0.0] - 2026-03-15**

### **Added**
🟦 Initial release of the core Docker Compose stack.  
🟦 Support for Plex, Radarr, Sonarr, and qBittorrent.  
