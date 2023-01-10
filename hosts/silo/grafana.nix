{ config, ... }:
{
  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "silo";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
        }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 3001;
    };
    provision.datasources.settings.datasources = [{
      url = "http://127.0.0.1:${toString config.services.prometheus.port}";
      name = "Silo Prometheus";
      type = "prometheus";
    }];
  };

  services.nginx.virtualHosts."grafana.winny.tech" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/empty";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}/";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_pass_request_headers on;
      '';
    };
  };
}
