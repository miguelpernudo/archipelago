{ config, pkgs, lib, ... }: 

{
  systemd.services.goflow2 = {
    description = "GoFlow2 — NetFlow/IPFIX/sFlow collector";
    wantedBy = [ "multi-user.target" ];
    after    = [ "network.target" ];
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.goflow2}/bin/goflow2"
        "-listen=:2055"
        "-listen.sflow=:6343"
        "-metrics=:8080"
      ];
      Restart   = "always";
      RestartSec = 5;
      DynamicUser = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  networking.nftables.ruleset = lib.mkAfter ''
    table inet filter {
      chain input {
        udp dport { 2055, 6343 } ip saddr { 192.168.0.0/16, 10.100.0.0/24 } accept;
      }
    }
  '';
}
