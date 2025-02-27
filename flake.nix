{
  description = "A simple home configuration manager for NixOS";

  outputs = { self }: {
    nixosModules.home-config = import ./default.nix;
    nixosModules.default = self.nixosModules.home-config;
  };
}
