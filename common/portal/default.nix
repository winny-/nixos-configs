{ pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: rec {
    portal-www-root = pkgs.callPackage ./portal-www-root {};
  };

  environment.systemPackages = [ pkgs.portal-www-root ];

  services.nginx = {
    enable = true;
    virtualHosts.localhost = {
      locations."/cups" = {
        return = "302 http://localhost:631/";
      };
      locations."/netdata" = {
        return = "302 http://localhost:19999/";
      };
      locations."/syncthing" = {
        return = "302 http://localhost:8384/";
      };
      root = "${pkgs.portal-www-root}/share/portal/www/";
    };
  };
}
