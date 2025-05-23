{ lib, config, ... }:
let
  cfg = config.neovim.plugins.todo-comments;
in {
  options = {
    neovim.plugins.todo-comments = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.neovim.nixvim.enable;
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.nixvim = {
        plugins.todo-comments = {
          enable = true;
        };
        # keymaps = [
        #   { mode = [ "n" ]; key = "<leader>vd"; action = "<cmd>todo-comments Diagnostics<CR>"; options = { noremap = true; silent = true; desc = "View Diagnostics"; }; }
        # ];
      };
    }
  ]);
}
