# See https://github.com/NixOS/nixpkgs/pull/177254

{
  lib,
  pkgs,
  stdenv,
  fetchgit,
  ...
}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "tic-80";
  version = "1.0.2164";

  src = fetchgit {
    url = "https://github.com/nesbox/TIC-80";
    rev = "v" + version;
    sha256 = "sha256-SnaAhdYoblxKlzTSyfcnvY6u7X6aIJIYWZAXtL2IIXc=";
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;
  dontStrip = true;
  nativeBuildInputs = [ cmake pkg-config ];
  # nativeBuildInputs = [  ];
  # propagatedBuildInputs = [ ];
  # buildInputs = [  ];

  # installPhase = ''
  # '';

  meta = with lib; {
    description = "A free and open source fantasy computer for making, playing and sharing tiny games";
    longDescription = ''
      TIC-80 is a free and open source fantasy computer for making, playing and
      sharing tiny games.

      There are built-in tools for development: code, sprites, maps, sound
      editors and the command line, which is enough to create a mini retro
      game. At the exit you will get a cartridge file, which can be stored and
      played on the website.

      Also, the game can be packed into a player that works on all popular
      platforms and distribute as you wish. To make a retro styled game the
      whole process of creation takes place under some technical limitations:
      240x136 pixels display, 16 color palette, 256 8x8 color sprites, 4
      channel sound and etc.

      Hardware Probe Tool is a tool to probe for hardware, check it's
      operability and find drivers. The probes are uploaded to the Linux
      hardware database. See https://linux-hardware.org for more information.
    '';
    homepage = "https://github.com/nesbox/TIC-80/";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ winny ];
  };
}
