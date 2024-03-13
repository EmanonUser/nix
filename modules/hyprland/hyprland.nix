{
  pkgs,
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      hyprpaper
      hyprpicker
      xdg-desktop-portal-hyprland
      copyq
      mako
    ];

    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.plugins = [];

    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";

      bind = [
        "$mod, ampersand, workspace, 1"
        "$mod SHIFT, ampersand, movetoworkspace, 1"
        "$mod, eacute, workspace, 2"
        "$mod SHIFT, eacute, movetoworkspace, 2"
        "$mod, quotedbl, workspace, 3"
        "$mod SHIFT, quotedbl, movetoworkspace, 3"
        "$mod, apostrophe, workspace, 4"
        "$mod SHIFT, apostrophe, movetoworkspace, 4"
        "$mod, parenleft, workspace, 5"
        "$mod SHIFT, parenleft, movetoworkspace, 5"
        "$mod, egrave, workspace, 6"
        "$mod SHIFT, egrave, movetoworkspace, 6"
        "$mod, minus, workspace, 7"
        "$mod SHIFT, minus, movetoworkspace, 7"
        "$mod, underscore, workspace, 8"
        "$mod SHIFT, underscore, movetoworkspace, 8"
        "$mod, ccedilla, workspace, 9"
        "$mod SHIFT, underscore, movetoworkspace, 9"
        "$mod, agrave, workspace, 10"
        "$mod SHIFT, agrave, movetoworkspace, 10"

        "$mod, a, exec, alacritty"
        "$mod, z, exec, wofi --show drun"
        "$mod, q, killactive,"
        "$mod, m, exit,"
        "$mod, s, togglefloating,"
        "$mod, p, pseudo,"
        "$mod, left, movefocus,l"
        "$mod, right, movefocus,r"
        "$mod, up, movefocus,u"
        "$mod, down, movefocus,d"
        "$mod, g, togglegroup"
        "$mod, tab, changegroupactive"
        "$mod, f, fullscreen"
        "$mod, c, centerwindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_SINK@ 5%-"
        ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_SINK@ toggle "
      ];

      input = {
        kb_layout = "fr";
        kb_variant = "";
        follow_mouse = 1;
        sensitivity = 0;
        mouse_refocus = false;
        force_no_accel = 1;
      };

      monitor = [
        "DP-2,      1920x1080@165,    1920x0,   1, vrr, 1"
        "DVI-D-1,   1920x1080@60,     0x0,      1"
      ];

      misc = {
        vrr = 1;
      };

      exec-once = [
        "copyq --start-server"
        "mako"
      ];
    };
  };
}
