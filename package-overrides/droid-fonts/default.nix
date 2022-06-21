{ lib, stdenvNoCC, ... }:
stdenvNoCC.mkDerivation {
  # See https://git.alpinelinux.org/aports/tree/main/ttf-droid/APKBUILD
  name = "droid-fonts";

  src = ./src;

  dontBuild = true;

  installPhase = ''
    install -m 755 -d $out/share/fonts/truetype
    install -m 444 *.ttf $out/share/fonts/truetype/
  '';
}
