{ config, pkgs, ... }:

# https://wiki.nftables.org

{
  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    ruleset = ''
      flush ruleset
      
      define LAN = 192.168.0.0/16
      # define WG = 10.100.0.0/24    # WireGuard client tunnel
      
      table inet filter {

        chain input {
          type filter hook input priority filter; policy drop;

          ct state established,related accept;
          ct state invalid drop;
          iifname "lo" accept;

          # ICMP
          ip  protocol icmp limit rate 10/second burst 20 packets accept;
          ip6 nexthdr icmpv6 icmpv6 type {
            nd-neighbor-solicit, nd-neighbor-advert,
            nd-router-advert,    nd-router-solicit
          } accept;
          
          ip6 nexthdr icmpv6 limit rate 10/second burst 20 packets accept;

          # SSH (LAN and WireGuard client tunnel)
          tcp dport 22 meta nfproto ipv4 ip saddr { $LAN, $WG } ct state new meter ssh_brute { ip saddr timeout 2m limit rate 3/minute burst 5 packets } accept;

          # WireGuard (client mode — no listening port needed).
          # udp dport 51820 accept;

          # DNS 
          # tcp dport 53 ip saddr $LAN accept;
          # udp dport 53 ip saddr $LAN accept;

          # Services, by VPN
          ip saddr $WG tcp dport {
            80, 443,   # Traefik (Grafana, Vaultwarden, Gitea)
            6443,      # K3s API (kubectl)
            8428,      # VictoriaMetrics
            30220,     # Gitea SSH
          } accept;

          # Services, by LAN.
          ip saddr $LAN tcp dport {
            80, 443,   # Traefik (Grafana, Vaultwarden, Gitea)
            6443,      # K3s API (kubectl)
            8428,      # VictoriaMetrics
            30220,     # Gitea SSH
          } accept;

          counter log prefix "NFT-DROP: " limit rate 5/minute drop;
        }

        chain forward {
          type filter hook forward priority filter;
          policy drop;
          ct state established,related accept;
          ct state invalid drop;

          # WireGuard.
          # iifname "wg0" oifname "enp2s0" accept;
        }

        chain output {
          type filter hook output priority filter;
          policy accept;
        }
      }

      # Masquerade for WireGuard.
      # table ip nat {
      #   chain postrouting {
      #     type nat hook postrouting priority srcnat;
      #     # oifname "enp2s0" masquerade;
      #     ip saddr $WG oifname "enp2s0" masquerade;
      #   }
      # }
    '';
  };
}
