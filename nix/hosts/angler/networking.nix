{ config, lib, hostname, ... }:

{
  imports = [
    ./firewall.nix

    ../../modules/network/dns.nix
    ../../modules/network/kea.nix
    ../../modules/network/unbound.nix
  ];

  networking.hostName = hostname;

  networking.networkmanager.enable = lib.mkDefault false;
  networking.useNetworkd = true;

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp*";
    networkConfig.DHCP = "yes";
  };

  systemd.network.networks."20-lan" = {
    matchConfig.Name = "enx*";
    networkConfig = {
      Address = "10.10.0.1/24";
      DHCPServer = false;
      LinkLocalAddressing = "no";
    };
  };
}
