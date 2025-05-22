{ config, lib, pkgs, ... }:

let
  update-home-configs = cfg: basedir: let
    allPaths = builtins.attrValues cfg;
    removeBaseDir = lib.path.removePrefix basedir;
    pathList = builtins.map removeBaseDir allPaths;
    text = lib.strings.concatLines pathList;
  in pkgs.replaceVarsWith {
    src = ./update-home-configs.sh;
    isExecutable = true;
    dir = "bin";
    replacements = {
      packagesList = pkgs.writeText "packages.txt" text;
    };
  };

in {
  options = {
    home-config = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      description = "Path to the folder with configs";
      example = {
        i3 = ./home-config;
      };
    };
    home-config-basedir = lib.mkOption {
      type = lib.types.path;
      description = "The basedir which update-home-configs will replace by the first argument";
      example = ./.;
    };
  };

  config.environment.systemPackages = [
    (update-home-configs config.home-config config.home-config-basedir)
  ];
}
