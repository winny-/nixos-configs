{
  description = "Winny's NixOS Configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
  };

  outputs = inputs: {
    nixosConfigurations =
      inputs.nixpkgs.lib.genAttrs [ "voyager" ] (hostName:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (./. + "/hosts/${hostName}")
          ];
          specialArgs = { inherit inputs; };
        });
  };
}
