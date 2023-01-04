{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      root_url = "https://silo.winny.tech/grafana/"; # Not needed if it is `https://your.domain/`
      domain = "silo.winny.tech";
      http_addr = "127.0.0.1";
      http_port = 3000;
    };
  };
  services.nginx.virtualHosts."silo.winny.tech".locations."/grafana" = {
    proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}/grafana";
    recommendedProxySettings = true;
    proxyWebsockets = true;
  };

}
