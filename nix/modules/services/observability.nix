{ config, pkgs, lib, ... }:

let
  blackboxConfig = pkgs.writeText "blackbox.yml" (builtins.toJSON {
    modules = {
      http_2xx.prober = "http";
      icmp.prober     = "icmp";
    };
  });
in
{
  services.victoriametrics = {
    enable           = true;
    listenAddress    = ":8428";
    retentionPeriod  = "30d";

    prometheusConfig.scrape_configs = [
      {
        job_name  = "node";
        static_configs = [{
          targets = [ "localhost:9100" ];
        }];
      }
      {
        job_name = "blackbox";
        metrics_path = "/probe";
        params.module = [ "http_2xx" "icmp" ];
        static_configs = [{
          targets = [
            "http://localhost:30800"
            "http://localhost:30300"
            "http://127.0.0.1:3001"
            "1.1.1.1"
          ];
        }];
        relabel_configs = [
          { source_labels = [ "__address__" ]; target_label = "__param_target"; }
          { source_labels = [ "__param_target" ]; target_label = "instance"; }
          { target_label = "__address__"; replacement = "127.0.0.1:9115"; }
        ];
      }
    ];
  };

  systemd.services.prometheus-node-exporter = {
    description = "Prometheus node exporter";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.prometheus-node-exporter}/bin/node_exporter"
        "--web.listen-address=:9100"
        "--collector.cpu" "--collector.diskstats" "--collector.filesystem"
        "--collector.loadavg" "--collector.meminfo" "--collector.netdev"
        "--collector.systemd" "--collector.thermal_zone"
      ];
      Restart = "always";
      RestartSec = 1;
      DynamicUser = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };

  systemd.services.prometheus-blackbox-exporter = {
    description = "Prometheus blackbox exporter";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.prometheus-blackbox-exporter}/bin/blackbox_exporter"
        "--web.listen-address=:9115"
        "--config.file=${blackboxConfig}"
      ];
      Restart = "always";
      RestartSec = 1;
      DynamicUser = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_NET_RAW" ];
    };
  };

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
      name      = "VictoriaMetrics";
      type      = "prometheus";
      url       = "http://localhost:8428";
      isDefault = true;
    }];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.grafana = {
      rule             = "Host(`angler`)";
      service          = "grafana";
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
