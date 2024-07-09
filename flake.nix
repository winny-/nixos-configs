{
  description = "Winny's NixOS Configurations";
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    jhmod.url = "github:sector-f/jhmod/c8b5242ae5b716d55ba0d5f30fdc0ea7e0583372";
    flake-utils.url = "github:numtide/flake-utils/a1720a10a6cfe8234c0e93907ffe81be440f4cef";
  };

  outputs = { self, nixpkgs, jhmod, flake-utils, ... }@inputs:
    with nixpkgs.lib;
    let
      hosts = builtins.attrNames (builtins.readDir ./hosts);
      unstable = inputs.unstable.legacyPackages.x86_64-linux;
      merged = (genAttrs hosts (hostName:
              nixosSystem {
                system = "x86_64-linux";
                modules = [
                  (./. + "/hosts/${hostName}")
                  ({ ... }: {
                    nix.registry.nixpkgs.flake = nixpkgs;
                    nix.nixPath = ["nixpkgs=${nixpkgs}"];
                  })
                ];
                specialArgs = { inherit inputs; inherit unstable; };
              })) // {
                livecd.minimal = nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                        "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                        ./livecd/minimal
                    ({ ... }: {
                      nix.registry.nixpkgs.flake = nixpkgs;
                      nix.nixPath = ["nixpkgs=${nixpkgs}"];
                    })
                  ];
                  specialArgs = { inherit inputs; inherit unstable; };
                };
              };
    in
      {
        nixosConfigurations = merged;
      };
}
