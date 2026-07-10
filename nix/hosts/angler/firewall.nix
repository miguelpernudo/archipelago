{ config, pkgs, ... }:

{
  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    ruleset = ''
      flush ruleset
      
      define LAN = 192.168.0.0/16
      
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

          # SSH
          tcp dport 22 ip saddr $LAN ct state new meter ssh_brute { ip saddr timeout 2m limit rate 3/minute burst 5 packets } accept;

          # Grafana
          tcp dport 3001 ip saddr $LAN accept;

          # VictoriaMetrics
          tcp dport 8428 ip saddr $LAN accept;

          # FreeRADIUS
          udp dport 1812-1813 ip saddr $LAN accept;

          # GoFlow2 (NetFlow/sFlow)
          udp dport { 2055, 6343 } ip saddr $LAN accept;

          counter log prefix "NFT-DROP: " limit rate 5/minute drop;
        }

        chain forward {
          type filter hook forward priority filter;
          policy drop;
          ct state established,related accept;
          ct state invalid drop;
        }

        chain output {
          type filter hook output priority filter;
          policy accept;
        }
      }
    '';
  };
}
