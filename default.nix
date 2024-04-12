{ config, lib, pkgs, ... }:

let
  update-home-configs = cfg: basedir: let
    replaceBaseDir = dir: ''"$BASEDIR${lib.strings.removePrefix basedir dir}"'';
    stowArgs = dir: ''stow --dotfiles -v --no-folding -d ${replaceBaseDir dir} -t "$HOME" "$@"'';
    buildArgs = x: (stowArgs x.dir) + " " + (lib.strings.concatStringsSep " " x.packages);
    args = builtins.map buildArgs (builtins.attrValues cfg);
  in pkgs.writeShellApplication {
    name = "update-home-configs";
    runtimeInputs = [ pkgs.stow ];
    text = ''
      BASEDIR="$1" # ${basedir}
      shift
      ${lib.strings.concatStringsSep "\n" args}
    '';
  };
  packageOps = {
    options = {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Package names to install";
        example = [ "sx" "vifm" "mpv" ];
      };
      dir = lib.mkOption {
        type = lib.types.str;
        description = "Path to the folder with packages";
        example = builtins.toString ./home-config;
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
          dir = builtins.toString ./home-config;
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
