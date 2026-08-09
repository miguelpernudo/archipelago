{ config, pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    gimp
    vlc
    vesktop
    spotify
    karere
    croc
  ];
}
