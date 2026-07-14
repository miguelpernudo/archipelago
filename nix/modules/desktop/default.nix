{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./gaming.nix
    ./fonts.nix
    ./gnome.nix
    #./cosmic.nix
  ];

  services.xserver.enable  = true;
  hardware.graphics.enable = true;
  security.polkit.enable   = true;

  xdg.portal.enable = true; 
  environment.systemPackages = with pkgs; [
    xdg-user-dirs
    xdg-utils
    wl-clipboard
  ];
 
  services.flatpak.enable  = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  environment.variables = {
    NIXOS_OZONE_WL  = "1";
    MOZ_ENABLE_WAYLAND = 1;
    
    QT_QPA_PLATFORM = "wayland";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    
    WLR_NO_HARDWARE_CURSORS = 1;
    #GDK_BACKEND = "wayland,x11";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    SDL_VIDEODRIVER = "wayland,x11";
  };
}
