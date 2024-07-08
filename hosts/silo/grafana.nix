# This configuration borrows largely from this wonderful blog post:
#
# https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20
#

{ config, lib, ... }:
{
  networking.firewall.allowedTCPPorts = [ 1514 ];
  networking.firewall.allowedUDPPorts = [ 1514 ];
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_port = 3030;
      ingester = {
        lifecycler = {
          address = "[::]";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 1048576;
        chunk_retain_period = "30s";
        max_transfer_retries = 0;
      };
      schema_config.configs = [{
        from = "2023-03-17";
        store = "boltdb-shipper";
        object_store = "filesystem";
        schema = "v11";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];
      storage_config = {
        filesystem.directory = "/var/lib/loki/chunks";
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          shared_store = "filesystem";
          cache_ttl = "24h";
        };
      };
      compactor = {
        working_directory = "/var/lib/loki";
        shared_store = "filesystem";
        compactor_ring.kvstore.store = "inmemory";
        retention_enabled = true;
      };
      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };
      chunk_store_config.max_look_back_period = "0s";
      table_manager = {
        retention_deletes_enabled = true;
        retention_period = "180d";
      };
    };
  };
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };
      positions.filename = "/tmp/positions.yml";
      clients = [{
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
      }];
      scrape_configs = [{
        job_name = "syslog";
        syslog = {
          listen_address = "[::]:1514";
          listen_protocol = "tcp";
          idle_timeout = "60s";
          label_structured_data = true;
          labels.job = "syslog";
        };
        relabel_configs = [{
          source_labels = ["__syslog_message_hostname"];
          target_label = "host";
        }];
      } {
        job_name = "syslog-udp";
        syslog = {
          listen_address = "[::]:1514";
          listen_protocol = "udp";
          idle_timeout = "60s";
          label_structured_data = true;
          labels.job = "syslog";
        };
        relabel_configs = [{
          source_labels = ["__syslog_message_hostname"];
          target_label = "host";
        }];
      } {
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = "silo";
          };
        };
        relabel_configs = [{
          source_labels = ["__journal__systemd_unit"];
          target_label = "unit";
        } {
          source_labels = ["__journal_syslog_identifier"];
          target_label = "syslog_identifier";
        }];
      }];
    };
  };

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
        configFile = builtins.toFile "blackbox_exporter.yml" (builtins.toJSON { # Some reason lib.generators.toYAML errors out :s
          modules = {
            http_2xx = {
              prober = "http";
              timeout = "15s";
              http = {
                fail_if_not_ssl = true;
                ip_protocol_fallback = false;
                method = "GET";
                no_follow_redirects = false;
                preferred_ip_protocol = "ip4";
                valid_http_versions = ["HTTP/1.1" "HTTP/2.0"];
              };
            };
            icmp = {
              prober = "icmp";
              timeout = "5s";
              icmp.preferred_ip_protocol = "ip4";
            };
          };
        });
      };
    };
    scrapeConfigs = [
      {
        job_name = "silo";
        static_configs = [{
          labels.host = "silo";
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
          labels.host = "toybox";
        }];
      }
      {
        job_name = "styx";
        static_configs = [{
          targets = [ "styx.home.winny.tech:9100" ];
          labels.host = "styx";
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
            "2606:4700::1111"
            "1.1.1.1"
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
      server.root_url = "https://grafana.winny.tech/";
      server.http_port = 3001;
      "auth.anonymous" = {
        enabled = "false";
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
    } {
      url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
      type = "loki";
      name = "Silo Loki";
      jsonData.maxLines = 1000;
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
