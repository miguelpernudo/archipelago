{ config, pkgs, lib, ... }:

let
  raddb = pkgs.runCommand "freeradius-config" {} ''
    cp -r ${pkgs.freeradius}/etc/raddb/* $out/
    chmod +w "$out/clients.conf"
    cat > "$out/clients.conf" << EOF
    client localhost {
      ipaddr = 127.0.0.1
      secret = testing123
    }
    client lan {
      ipaddr = 192.168.0.0/16
      secret = testing123
      shortname = lan
    }
    EOF
  '';
in {
  services.freeradius = {
    enable = true;
    configDir = raddb;
  };

  networking.nftables.ruleset = lib.mkAfter ''
    table inet filter {
      chain input {
        udp dport 1812-1813 ip saddr { 192.168.0.0/16, 10.100.0.0/24 } accept;
      }
    }
  '';
}
