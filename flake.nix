{
  description = "Winny's NixOS Configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    jhmod.url = "github:sector-f/jhmod/4470eba57f3c3969ab04ef1be1dbf761be5a2c0f";
    flake-utils.url = "github:numtide/flake-utils/6ee9ebb6b1ee695d2cacc4faa053a7b9baa76817";
  };

  outputs = { self, nixpkgs, jhmod, flake-utils }@inputs:
    with nixpkgs.lib;
    let
      hosts = builtins.attrNames (builtins.readDir ./hosts);
      merged = (genAttrs hosts (hostName:
              nixosSystem {
                system = "x86_64-linux";
                modules = [
                  (./. + "/hosts/${hostName}")
                  ({ ... }: {
                    nix.registry.nixpkgs.flake = nixpkgs;
                  })
                ];
                specialArgs = { inherit inputs; };
              })) // {
                livecd.minimal = nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                        "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                        ./livecd/minimal
                    ({ ... }: {
                      nix.registry.nixpkgs.flake = nixpkgs;
                    })
                  ];
                  specialArgs = { inherit inputs; };
                };
              };
    in
      {
        nixosConfigurations = merged;
        apps.repl = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "repl" ''
            confnix=$(mktemp)
            echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
            trap "rm $confnix" EXIT
            nix repl $confnix
          '';
        };
      };
}
