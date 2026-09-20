{ config, pkgs, pkgs-unstable, ... }:

{
    home.packages = with pkgs; [
      libreoffice
      joplin-desktop
      typst
      d2
      ltspice
      mono
      
      # logseq # depends on electron-39.8.10 but can't be whitelisted 
      # upstream due to a home-manager bug in this nixpkgs: 
      # nixpkgs.config.permittedInsecurePackages is not forwarded
      # to the hm generation pkgs instance.
      # pkgs-unstable.logseq  
    ];
}
