{
  description = "Winny's NixOS Configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    jhmod.url = "github:sector-f/jhmod/4470eba57f3c3969ab04ef1be1dbf761be5a2c0f";
  };

  outputs = { self, nixpkgs, jhmod }@inputs:
    let
      hosts = nixpkgs.lib.attrsets.mapAttrsToList
        (name: value: name)
        (builtins.readDir ./hosts);
    in
      {
        nixosConfigurations =
          nixpkgs.lib.genAttrs hosts (hostName:
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                (./. + "/hosts/${hostName}")
              ];
              specialArgs = { inherit inputs; };
            });
      };
}
