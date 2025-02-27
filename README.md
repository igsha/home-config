# home-config

A simple home configuration manager for NixOS.

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
          home-config-basedir = lib.mkForce ./.;
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
    dir = ./home-config;
  };
}
```

It is possible to use `dot-` prefix for hidden folders.
E.g., `.config` transforms to `dot-config`.
