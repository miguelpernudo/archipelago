# NetDev Infra

Monorepo for my homelab: a reproducible, self-hosted infrastructure
running on mixed hardware with Alpine Linux (one host) and NixOS (two hosts).

## Network

All traffic enters through the **Krill** gateway. It handles NAT, DNS, DHCP, Wi-Fi (hostapd), and traffic shaping (HTB QoS via tc).

 **WireGuard** connectivity is delegated to a separate bridge node
(not on any machine in this repo). Angler connects as a WG client
for remote access and service exposure.

## Services

All services run on **Angler** inside a **k3s** single-node cluster,
behind **Traefik** as the single reverse proxy entry point.

Traefik: Port 80/443 on host             
Vaultwarden: `vaultwarden.angler`
Gitea: `gitea.angler` (SSH via port 30220)
Grafana: `angler` (port 9090 for Prometheus)
Prometheus: Port 9090 (LAN only)

Kubernetes resources are deployed via k3s auto-manifests
(`--manifests-dir /etc/k3s-manifests`). No PVCs, single-node
storage uses hostPath.

Firewall rules are defined per-host as raw `nftables` rulesets,
in NixOS is `networking.nftables.ruleset`.

## Structure

```
gateway/            Alpine config (install.sh, nftables, hostapd, tc, health)
nix/
  flake.nix         Nix flake entry point
  hosts/
    angler/         NixOS configuration for Angler server
    orca/           NixOS configuration for Orca workstation
  modules/
    core/           Base system settings (locale, nix, etc.)
    desktop/        Desktop environments (KDE, GNOME, Wayfire)
    hardware/       Hardware-specific modules (TLP, etc.)
    home/           Home-manager user configs
    network/        DNS, traffic control, etc.
    security/       Audit, AppArmor, doas
    services/       k3s, Traefik, Vaultwarden, Gitea, Docker, SSH, etc.
    profiles/       Minimal / headless presets
.github/workflows/  CI (shellcheck, nftables validation, nix flake check)
```

## Roadmap

- [ ] **Provision Krill with Ansible**: Replace `install.sh` with
        idempotent automation.
- [ ] **Centralised logging**: Ship Krill logs to Loki on Angler
        via Promtail; correlate gateway, server, and workstation
        events in Grafana.
- [ ] **Firewall audit logging**: Log dropped packets on Krill
        (nftables `log prefix`) to detect port scans and
        suspicious traffic.
- [ ] **Backup infrastructure**: Borg backups from Angler and Orca
        to Krill's HDD over SSH; encrypted, deduplicated, scheduled.
- [ ] **Network simulation with Containerlab**: Model and test LAN
        topology, firewall rules, and routing before production.
- [ ] **Dedicated VPN bridge on a VPS**: WireGuard server in the
        cloud for stable remote access independent of residential
        connection.
- [ ] **TLS via Let's Encrypt**: Enable Traefik's certResolver
        once a public domain points at the VPS bridge.
- [ ] **eBPF observability**: Explore bpftrace and eBPF tooling
        for low-overhead network and performance debugging.
