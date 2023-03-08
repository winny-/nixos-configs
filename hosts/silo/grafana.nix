{ config, ... }:
{
  services.nginx.statusPage = true;
  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
      zfs.enable = true;
      systemd.enable = true;
      smartctl.enable = true;
      nginx.enable = true;
    };
    scrapeConfigs = [
      {
        job_name = "silo";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"
          ];
        }];
      }
      {
        job_name = "toybox";
        static_configs = [{
          targets = [ "toybox.home.winny.tech:9182" ];
        }];
      }
      {
        job_name = "styx";
        static_configs = [{
          targets = [ "styx.home.winny.tech:9100" ];
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
  services.nginx.virtualHosts."prometheus.winny.tech" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/empty";
    # This is "secure" because I don't mirror the built derivations
    # anywhere or allow other users to log into this server.  The
    # password should be world readable so I wouldn't depend on this for
    # anything too serious.
    basicAuth.prometheus = builtins.readFile "/secrets/prometheus/basic_auth";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}/";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_pass_request_headers on;
      '';
    };
  };

}
