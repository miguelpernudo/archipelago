# Bash aliases and functions to 
# simplify system maintenance.

{ config, ... }:

{
	programs.bash = {
  	enable = true;
  	
		shellAliases = {
		  # Clean the entire system, including older generations. 
		  # Then, update the bootloader to reflect the current list of generations.
      nixclean = "sudo nix-collect-garbage -d && cd /etc/nixos && sudo nixos-rebuild boot --flake .#$(hostname) && cd -";

      # Checks syntax and structure. Doesn't build anything.
      nixcheck = "nix flake check";
    };

    interactiveShellInit = ''
      # Current host rebuild.
      nixreb() {
        cd /etc/nixos
        sudo nixos-rebuild switch --flake .#$(hostname)
        cd -
      }

      # Remote host rebuild.
      # If you don't use sudo in the target host, like doas, 
      # this wouldn' work. Be careful.
      nixremote() {
        local host="$1"
        local user="$2"
        if [[ -z "$host" ]]; then
          echo "usage: nixremote <hostname> <user>"
          return 1
        fi
        if [[ -z "$user" ]]; then
          echo "usage: nixremote <hostname> <user>"
          return 1
        fi
        cd /etc/nixos
         nixos-rebuild switch --flake .#"$host" --target-host "$user"@"$host" --sudo --ask-sudo-password
         cd -
      }

      # Evaluate a Nix expression.
      nixinst() {
        nix-instantiate --eval -E "$1"
      }

      # Dry-build a system.
      nixdry() {
        if [[ -z "$1" ]]; then
          echo "usage: nixdry <hostname>"
          return 1
        fi

        cd /etc/nixos
        sudo nixos-rebuild dry-build --flake .#"$1"
        cd -
      }

      # Update, validate and rebuild.
      # nixupg: flake update + dry-build + boot
      # nixupg nodry: skip dry-build
      # nixupg switch: flake update + dry-build + switch 
      # nixupg switch nodry: skip dry-build + switch
      nixupg() {
        local action="''${1:-boot}"
        local verify="''${2:-dry}"
        cd /etc/nixos
        nix flake update
        if [[ "$verify" == "dry" ]]; then
          sudo nixos-rebuild dry-build --flake .#$(hostname)
        fi
        if [[ "$action" == "switch" ]]; then
          nixreb
        else
          sudo nixos-rebuild boot --flake .#$(hostname)
        fi
        cd -
      }
    '';
 	};
}
