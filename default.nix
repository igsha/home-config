{ config, lib, pkgs, ... }:

let
  formPackage = dir: basedir: p: lib.strings.removePrefix "/" "${lib.strings.removePrefix basedir dir}/${p}";
  mapPackages = ps: dir: basedir: builtins.map (formPackage dir basedir) ps;
  getPackagesList = cfg: basedir: lib.flatten (builtins.map (x: mapPackages x.packages x.dir basedir) (builtins.attrValues cfg));
  packages-list = cfg: basedir: pkgs.writeText "packages.txt"
    (builtins.concatStringsSep "\n" (getPackagesList cfg basedir));
  update-home-configs = cfg: basedir: pkgs.substituteAll {
    name = "update-home-configs";
    src = ./update-home-configs.sh.in;
    isExecutable = true;
    dir = "/bin/";
    packagesList = pkgs.writeText "packages.txt" (builtins.concatStringsSep "\n" (getPackagesList cfg basedir));
  };
  packageOps = {
    options = {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Package names to install";
        example = [ "sx" "vifm" "mpv" ];
      };
      dir = lib.mkOption {
        type = lib.types.path;
        description = "Path to the folder with packages";
        example = ./home-config;
      };
    };
  };

in {
  options = {
    home-config = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule packageOps);
      description = "Package set";
      example = {
        i3 = {
          packages = [ "sx" "vifm" "mpv" ];
          dir = ./home-config;
        };
      };
    };
    home-config-basedir = lib.mkOption {
      type = lib.types.str;
      description = "The basedir which update-home-configs will replace by the first argument";
      example = builtins.toString ./.;
    };
  };

  config.environment.systemPackages = [
    (update-home-configs config.home-config config.home-config-basedir)
  ];
}
