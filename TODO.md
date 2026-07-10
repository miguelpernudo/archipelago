# Roadmap

The homelab is shifting focus from general-purpose services to a **network-oriented infrastructure** built for learning low-level networking, eBPF, routing protocols, and access control. All declared as code.

## Angler as a frontier router

- [ ] **New architecture: ISP → Angler → Krill**
Move Angler from a standalone server to the network edge. ISP uplink via USB Ethernet; Krill bridges WiFi clients on the LAN side. Angler becomes the default gateway, DHCP server, DNS resolver, and firewall for the whole private network.

- [ ] **FRRouting + BGP**

- [ ] **Kea + Unbound**

- [ ] **eBPF/XDP firewall + observability**

- [ ] **Nftables harden + audit logging**

- [ ] **GoFlow2 + NetFlow telemetry**

- [ ] **802.1X + FreeRADIUS NAC**

## Automation

- [ ] **Provision Krill with Ansible**
Replace the manual `install.sh` with idempotent Ansible playbooks. Krill cannot run NixOS because its costrained hardware, so this is the best option to be reproducible.

- [ ] **Containerlab for network simulation**

- [ ] **Dedicated VPS**

## Observability and polish

- [ ] **Grafana overhaul**
Replace the generic system dashboard with network-focused views.

- [ ] **Backup infrastructure**

