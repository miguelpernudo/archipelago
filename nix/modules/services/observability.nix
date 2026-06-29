{ config, pkgs, ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3001;
        domain    = "angler";
      };
      security = {
        admin_user               = "admin";
        admin_password           = "$__file{${config.sops.secrets.grafana_password.path}}";
        secret_key               = "$__file{${config.sops.secrets.grafana_secret_key.path}}";
        disable_gravatar         = true;
        cookie_secure            = true;
      };
      analytics.reporting_enabled = false;
    };

    provision.datasources.settings.datasources = [{
      name      = "Prometheus";
      type      = "prometheus";
      url       = "http://localhost:${toString config.services.prometheus.port}";
      isDefault = true;
    }];
  };

  services.prometheus = {
    enable = true;
    port   = 9090;

    scrapeConfigs = [
      {
        job_name  = "node";
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "blackbox";
        # Blackbox recibe "/probe?target=URL" en vez de scrape directo.
        # Los relabels traducen cada target URL a ese formato.
        metrics_path = "/probe";
        params.module = [ "http_2xx" "icmp" ];
        static_configs = [{
          targets = [
            "http://localhost:30800"    # Vaultwarden
            "http://localhost:30300"    # Gitea
            "http://127.0.0.1:3001"    # Grafana
            "1.1.1.1"                   # Ping a internet
          ];
        }];
        relabel_configs = [
          # Copia la URL (eg "http://localhost:30800") al parametro target
          { source_labels = [ "__address__" ]; target_label = "__param_target"; }
          # Usa esa misma URL como label para identificar la metrica
          { source_labels = [ "__param_target" ]; target_label = "instance"; }
          # Cambia el destino: en vez de scrapear la URL, scrapea blackbox
          { target_label = "__address__"; replacement = "127.0.0.1:9115"; }
        ];
      }
    ];

    exporters = {
      node = {
        enable          = true;
        port            = 9100;
        enabledCollectors = [
          "cpu" "diskstats" "filesystem"
          "loadavg" "meminfo" "netdev"
          "systemd" "thermal_zone"
        ];
      };
      blackbox = {
        enable = true;
        configFile = pkgs.writeText "blackbox.yml" (builtins.toJSON {
          modules = {
            http_2xx.prober = "http";
            icmp.prober     = "icmp";
          };
        });
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.grafana = {
      rule             = "Host(`angler`)";
      service          = "grafana";
      # tls.certResolver = "letsencrypt";
    };
    services.grafana.loadBalancer.servers = [
      { url = "http://127.0.0.1:3001"; }
    ];
  };

  sops.secrets = {
    grafana_password = {};
    grafana_secret_key = {};
  };
}
