{ config, pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    vscodium
    opencode-desktop
    lazygit

    clang
    llvm
  ];
}
