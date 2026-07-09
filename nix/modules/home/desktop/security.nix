{ config, pkgs, ... }:

{
    home.packages = with pkgs; [
      ente-auth
      proton-vpn
      # bitwarden-desktop
    ];
}
