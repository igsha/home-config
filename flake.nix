{
  description = "A simple home configuration manager for NixOS";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules.home-config = import ./default.nix;
    nixosModules.default = self.nixosModules.home-config;
  };
}
