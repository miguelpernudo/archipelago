{ config, pkgs, ... }:

{
	dconf.settings = {
		"org/gnome/desktop/interface" = {
      gtk-theme = "Orchis-Teal-Dark";
			enable-animations = false;
		};
	};
    
  home.packages = with pkgs; [
    alacarte
    gnome-tweaks
    papirus-icon-theme
    ] ++ (with gnomeExtensions; [
    vitals
    blur-my-shell
    command-menu-2
    tiling-shell
    tiling-assistant
    just-perfection
    appindicator
    caffeine
    dash-in-panel
    #media-controls
    #cloudflare-warp-toggle
    #astra-monitor
    #dock-from-dash
    #arcmenu
    #unite
  ]);

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Classic";
    size = 22;
  };	

  gtk = {
    enable = true;
    theme = {
      package = pkgs.orchis-theme;
      name = "Orchis-Teal-Dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    font = {
          name = "Inter";
          package = pkgs.inter;
          size = 12;
        };
  };
}
