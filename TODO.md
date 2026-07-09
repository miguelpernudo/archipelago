# Roadmap

- [ ] **Provision Krill with Ansible**: Replace `install.sh` with
        idempotent automation.
- [ ] **FreeRADIUS on Angler**: Native NixOS service, WPA2-Enterprise
        auth for Krill's hostapd via RADIUS.
- [ ] **Netbox in k3s (or standalone)**: Model the full network
        topology (devices, prefixes, IPs, VLANs, circuits).
- [ ] **goflow2 on Angler**: NetFlow v5/v9 collector on UDP 2055,
        metrics to VictoriaMetrics; softflowd on Krill sends flows.
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
