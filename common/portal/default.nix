{ ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts.localhost = {
      locations."/cups" = {
        return = "302 http://localhost:631/";
      };
      locations."/netdata" = {
        return = "302 http://localhost:1999/";
      };
      locations."/syncthing" = {
        return = "302 http://localhost:8384/";
      };
      root = toString ./root;
    };
  };
}
