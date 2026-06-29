{ config, pkgs, ... }: {
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
        };
      };

      # certificatesResolvers.letsencrypt.acme = {
      #   email = "admin@domain";
      #   storage = "/var/lib/traefik/letsencrypt.json";
      #   httpChallenge.entryPoint = "web";
      # };
    };
  };
}
