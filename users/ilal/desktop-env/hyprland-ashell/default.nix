{ pkgs, lib, ... }: let
  readDirPaths = dir:
    map (name: "${dir}/${name}") (builtins.attrNames (builtins.readDir dir));
in {
  defaultSessionCmd = "${lib.getExe pkgs.hyprland}";
  packages = with pkgs; [
    hyprland
    hyprpaper
    hyprlock
    ashell
    rose-pine-hyprcursor

    # Just for Screenshot
    grim
    slurp
    grimblast
    satty
    # Applications
    kitty
    yazi
    walker

    # dependencies
    playerctl
    brightnessctl
    ddcutil
    wl-clipboard
  ];
  config_dir."hypr/plugins.conf".text = ''
  # exec-once = hyprctl plugin load ${pkgs.hyprlandPlugins.hyprbars}/lib/libhyprbars.so
  exec-once = hyprctl plugin load ${pkgs.hyprlandPlugins.hyprexpo}/lib/libhyprexpo.so
  bind = SUPER, Tab, hyprexpo:expo, toggle
  plugin {
    hyprbars {
      # Honestly idk if it works like css, but well, why not
      bar_text_font = Roboto, Noto Sans, sans-serif
      bar_height = 20
      bar_padding = 15
      bar_button_padding = 5
      bar_precedence_over_border = true
      bar_part_of_window = true

      # example buttons (R -> L)
      hyprbars-button = rgb(E93C2D), 16, 󰖭, hyprctl dispatch killactive
      hyprbars-button = rgb(FED200), 16, 󰖯, hyprctl dispatch fullscreen 1
      hyprbars-button = rgb(68A828), 16, 󰖰, hyprctl dispatch movetoworkspacesilent special
      hyprbars-button = rgb(FED200), 16, 󰓩, hyprctl dispatch togglegroup

      on_double_click = hyprctl dispatch fullscreen 1
    }
    hyprexpo {
      columns = 2
      gap_size = 5
      bg_col = rgb(111111)
      workspace_method = center current # [center/first] [workspace] e.g. first 1 or center m+1
      skip_empty = true

      gesture_distance = 300 # how far is the "max" for the gesture
    }
  }'';
  config_dir."hypr".directory = readDirPaths ./hypr;
  config_dir."ashell/config.toml".source  = ./ashell.toml;
  config_dir."walker".directory = readDirPaths ./walker;
  config_dir."satty/config.toml".source  = ./satty.toml;
}
