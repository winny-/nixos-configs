{ config, ... }:
{
  services.nginx.statusPage = true;
  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes"
        ];
        port = 9002;
      };
      zfs.enable = true;
      systemd.enable = true;
      smartctl.enable = true;
      nginx.enable = true;
      blackbox = {
        enable = true;
        configFile = ./blackbox_exporter.yml;
      };
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
            "127.0.0.1:${toString config.services.grafana.settings.server.http_port}"
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
      {
        job_name = "blackbox-http";
        metrics_path = "/probe";
        scrape_timeout = "15s";
        scrape_interval = "15s";
        params.module = ["http_2xx"];
        static_configs = [{
          targets = [
            "https://winny.tech"
            "https://blog.winny.tech"
            "https://gallery.winny.tech"
            "https://ircbox.winny.tech"
            "https://nc.winny.tech"
            "https://grafana.winny.tech"
          ];
        }];
        relabel_configs = [{
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        } {
          source_labels = [ "__param_target"];
          target_label = "instance";
        } {
          target_label = "__address__";
          replacement = "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}";
        }];
      }
      {
        job_name = "blackbox-icmp";
        metrics_path = "/probe";
        scrape_timeout = "15s";
        scrape_interval = "15s";
        params.module = ["icmp"];
        static_configs = [{
          targets = [
            "styx.home.winny.tech"
            "silo.home.winny.tech"
            "acheron.home.winny.tech"
            "printer.home.winny.tech"
            "wifi.home.winny.tech"
            "ircbox.winny.tech"
          ];
        }];
        relabel_configs = [{
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        } {
          source_labels = [ "__param_target"];
          target_label = "instance";
        } {
          target_label = "__address__";
          replacement = "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}";
        }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server.http_port = 3001;
      "auth.anonymous" = {
        enabled = "true";
        org_name = "winny.tech";
        org_role = "Viewer";
        hide_version = "true";
      };
      metrics.enabled = "true";
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
