Declarative multi-host configuration for a personal homelab and daily driver workstation. Two distinct machines managed from a single unified flake, eliminating configuration duplication.

---

## Hosts

### 🖥 Angler (Dell OptiPlex 3020)

**Role:** Frontier router, firewall, and network management plane.  
**Resources:** Intel Core i5-4590, 6 GB RAM, USB Ethernet (second NIC).  
**Status:** Active development (migrating).

**Key technologies (not implemented):**
- **Routing:** FRRouting with BGP.
- **Firewall:** nftables + eBPF/XDP programs on the uplink interface.
- **DHCP:** Kea with host reservations, Prometheus metrics.
- **DNS:** Unbound with DNSSEC, local zones (`*.angler`), metrics.
- **NAC:** FreeRADIUS for 802.1X (WPA2-Enterprise on Krill).
- **NetFlow:** GoFlow2 collector + softflowd senders for traffic telemetry.
- **Observability:** VictoriaMetrics + Grafana for BGP, flows, DHCP, DNS, eBPF.
- **Provisioning:** `nixos-anywhere` + `disko` for automated install.
- **Networking:** Per-host nftables firewall, SSH restricted to LAN (and future VPN).

---

### 💻 Orca (ThinkPad T14 Gen1)

**Role:** Daily driver workstation. Development, gaming, class, and *remote builder for Angler*.  
**Desktop Stack:** GNOME, and home manager.  
**Status:** Stable.
- **Shell:** Custom bash functions (`nixreb`, `nixremote`, `nixdry`, `nixupg`, `nixclean`) for workflow efficiency.

---

## Secrets Management

All secrets are encrypted with **sops-nix** using age keys. Each host has its own encrypted file under `secrets/`:

Secrets are decrypted at build time and never stored in plaintext. The CI pipeline (`gitleaks`) audits every push for accidental secret leakage.
