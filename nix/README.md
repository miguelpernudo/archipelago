Declarative multi-host configuration for a personal homelab and daily driver workstation. Two distinct machines managed from a single unified flake, eliminating configuration duplication.

---

## Hosts

### 🖥 Angler (Dell OptiPlex 3020)

**Role:** Headless network homelab server.  
**Resources:** Intel Core i5-4590, 6 GB RAM.  
**Status:** Active development.

**Key technologies:**
- **Provisioning:** `nixos-anywhere` + `disko` for automated disk partitioning and remote installation.
- **Kubernetes:** Single-node k3s cluster with auto-manifests (`/etc/k3s-manifests`).
- **Reverse proxy:** Traefik as single entry point (ports 80/443) with hostname-based routing served on gateway Krill.
- **Services:** Vaultwarden and Gitea deployed as k3s manifests behind Traefik; Gitea SSH via direct NodePort 30220.
- **Container runtime:** Docker CE with Compose v2, buildKit enabled, automatic cleanup.
- **Networking:** Per-host nftables firewall, SSH restricted to LAN/VPN.
- **Observability:** Prometheus + Grafana for node metrics. Blackbox exporter for external probing (service health, internet reachability).

---

### 💻 Orca (ThinkPad T14 Gen1)

**Role:** Daily driver workstation. Development, gaming, class, and *remote builder for Angler*.  
**Desktop Stack:** GNOME 50 on Wayland, and home manager.  
**Status:** Stable.


**Key technologies:**
- **Development:** Micro editor, VSCodium, Go toolchain, Ansible, Docker.
- **Shell:** Custom bash functions (`nixreb`, `nixremote`, `nixdry`, `nixupg`, `nixclean`) for workflow efficiency.
- **Terminal:** Ghostty with oceanic theme.

---

## Secrets Management

All secrets are encrypted with **sops-nix** using age keys. Each host has its own encrypted file under `secrets/`:

Secrets are decrypted at build time and never stored in plaintext. The CI pipeline (`gitleaks`) audits every push for accidental secret leakage.
