{ config, pkgs, ... }:

{
  networking.firewall.enable = false;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.nftables = {
    enable = true;
    ruleset = ''
      flush ruleset

      define LAN = 10.10.0.0/24

      table inet filter {
        chain input {
          type filter hook input priority filter; policy drop;

          ct state established,related accept;
          ct state invalid drop;
          iifname "lo" accept;

          ip  protocol icmp limit rate 10/second burst 20 packets accept;
          ip6 nexthdr icmpv6 icmpv6 type {
            nd-neighbor-solicit, nd-neighbor-advert,
            nd-router-advert,    nd-router-solicit
          } accept;
          ip6 nexthdr icmpv6 limit rate 10/second burst 20 packets accept;

          tcp dport 22 ip saddr $LAN ct state new meter ssh_brute \
            { ip saddr timeout 2m limit rate 3/minute burst 5 packets } accept;

          tcp dport 3001 ip saddr $LAN accept;
          tcp dport 8428 ip saddr $LAN accept;
          udp dport 1812-1813 ip saddr $LAN accept;
          udp dport { 2055, 6343 } ip saddr $LAN accept;

          counter log prefix "NFT-INPUT-DROP: " limit rate 5/minute drop;
        }

        chain forward {
          type filter hook forward priority filter;
          policy drop;

          ct state established,related accept;
          ct state invalid drop;

          iifname "enx*" oifname "enp*" accept;

          counter log prefix "NFT-FWD-DROP: " limit rate 3/minute drop;
        }

        chain output {
          type filter hook output priority filter;
          policy accept;
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority srcnat;
          policy accept;
          oifname "enp*" ip saddr $LAN masquerade;
        }
      }
    '';
  };
}
