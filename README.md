# home-config

A simple home configuration manager for NixOS.
It is based on `stow`.

# Usage

In flake:
```nix
{
  inputs.home-config = "github:igsha/home-config/main";
  outputs = { home-config, ... }: {
    nixosConfigurations.<hostname> = {
      ...
      modules = [
        home-config.nixosModules.default
        ({ lib, ... } : {
          home-config-basedir = lib.mkForce (builtins.toString ./.);
        })
        ...
      ];
    };
  };
}
```

Create `home-config` folder with a `.config` stuff and add to configuration:
```nix
{ pkgs, lib, config, ... }:

{
  ...
  home-config.lala = {
    packages = [ "lala" ]; # lala - is folder inside home-config folder
    dir = builtins.toString ./home-config;
  };
}
```
