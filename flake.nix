{
  description = "Winny's NixOS Configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    jhmod.url = "github:sector-f/jhmod/4470eba57f3c3969ab04ef1be1dbf761be5a2c0f";
  };

  outputs = { self, nixpkgs, jhmod }@inputs:
    let
      hosts = builtins.attrNames (builtins.readDir ./hosts);
    in
      {
        nixosConfigurations =
          nixpkgs.lib.genAttrs hosts (hostName:
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                (./. + "/hosts/${hostName}")
                ({ ... }: {
                  nix.registry.nixpkgs.flake = nixpkgs;
                })
              ];
              specialArgs = { inherit inputs; };
            });
      };
}
