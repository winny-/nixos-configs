{ lib, stdenvNoCC, ... }:
stdenvNoCC.mkDerivation {
  name = "portal-www-root";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    install -m 755 -d $out/share/portal/www
    cp -r root/* $out/share/portal/www/
  '';
}
