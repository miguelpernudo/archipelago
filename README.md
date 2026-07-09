# Archipelago

Monorepo for my workstation and homelab: a reproducible, self-hosted infrastructure
running on mixed hardware with Alpine Linux (*Krill*) and NixOS (*Angler*, *Orca*).

## Network

Currently, all traffic enters through ISP Router, the **Krill** gateway acts as a secure and isolated access point. It handles NAT, DNS, DHCP, and traffic shaping (HTB QoS via TC).

**WireGuard** connectivity is delegated to a separate bridge node
(not on any machine in this repo). Angler connects as a WG client
for remote access and service exposure.

## Services

All services run on **Angler** inside a **k3s** single-node cluster,
behind **Traefik** as the single reverse proxy entry point.

Traefik: Port 80/443 on host             
Grafana: `angler`
VictoriaMetrics: Port 8428 (LAN only)
FreeRADIUS: Port 1812-1813/udp (LAN only)
Netbox: `netbox.angler`
goflow2: Port 2055/udp (NetFlow collector)

Kubernetes resources are deployed via k3s auto-manifests
(`--manifests-dir /etc/k3s-manifests`). No PVCs, single-node
storage uses hostPath.

Firewall rules are defined per-host as raw `nftables` rulesets,
in NixOS is `networking.nftables.ruleset`.

## Structure

```
gateway/            Alpine config (install.sh, nftables, hostapd, scripts...)
nix/
  flake.nix         Nix flake entry point
  hosts/
    angler/         NixOS configuration for Angler (homelab)
    orca/           NixOS configuration for Orca (workstation)
  modules/
    core/           Base system settings (locale, nix...)
    desktop/        Desktop related (GNOME, gaming...)
    hardware/       Hardware-specific modules (TLP...)
    home/           Home-manager user configs
    network/        DNS, traffic control, etc.
    security/       Audit, AppArmor...
    services/       k3s, Traefik, Docker...
    profiles/       Minimal/headless presets
.github/workflows/  CI (shellcheck, nftables validation, nix flake check)
```
