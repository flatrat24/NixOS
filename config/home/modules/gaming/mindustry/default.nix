{ pkgs, lib, config, ... }:
let
  cfg = config.gaming.mindustry;
  dependencies = with pkgs; [ ];
in {
  options = {
    gaming = {
      mindustry.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        mindustry-wayland
      ];
    }
    (lib.mkIf (config.hyprland.enable) {
      wayland.windowManager.hyprland.settings.windowrulev2 = [ # TODO: Make windowrule for mindustry
        "float,class:Mindustry,title:Mindustry"
        "size 75% 75%,class:Mindustry,title:Mindustry"
        "move 12.5% 12.5%,class:Mindustry,title:Mindustry"
      ];
    })
  ]);
}
