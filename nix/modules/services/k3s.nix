{ config, pkgs, ... }: 

{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--disable" "traefik"
      "--disable" "servicelb"
      "--manifests-dir" "/etc/k3s-manifests"
    ];
  };

  environment.systemPackages = with pkgs; [ 
    kubectl 
    
    cilium-cli 
    helm 
  ];
}
