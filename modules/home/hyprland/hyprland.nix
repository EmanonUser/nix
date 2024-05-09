{pkgs, ...}: {
  home.packages = with pkgs; [
    hyprpaper
    hyprpicker
    xdg-desktop-portal-hyprland
    copyq
    mako
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    "$w1" = "Code";
    "$w2" = "Browser";

    bind = [
      "$mod, ampersand, workspace, 1"
      "$mod, eacute, workspace, 2"
      "$mod, quotedbl, workspace, 3"
      "$mod, apostrophe, workspace, 4"
      "$mod, parenleft, workspace, 5"
      "$mod, egrave, workspace, 6"
      "$mod, minus, workspace, 7"
      "$mod, underscore, workspace, 8"

      "$mod SHIFT, ampersand, movetoworkspace, 1"
      "$mod SHIFT, eacute, movetoworkspace, 2"
      "$mod SHIFT, quotedbl, movetoworkspace, 3"
      "$mod SHIFT, apostrophe, movetoworkspace, 4"
      "$mod SHIFT, parenleft, movetoworkspace, 5"
      "$mod SHIFT, egrave, movetoworkspace, 6"
      "$mod SHIFT, minus, movetoworkspace, 7"
      "$mod SHIFT, underscore, movetoworkspace, 8"

      "$mod, a, exec, alacritty"
      "$mod, z, exec, wofi --show drun"
      "$mod, q, killactive,"
      "$mod, m, exit,"
      "$mod, s, togglefloating,"
      "$mod, p, pseudo,"
      "$mod, g, togglegroup"
      "$mod, tab, changegroupactive"
      "$mod, f, fullscreen"
      "$mod, c, centerwindow"
      "SUPER_SHIFT, s, exec, grimblast copysave area"
      ", Print, exec, grimblast copysave active"

      "$mod, left, movefocus,l"
      "$mod, right, movefocus,r"
      "$mod, up, movefocus,u"
      "$mod, down, movefocus,d"

      "SUPER SHIFT, left, movewindow, l"
      "SUPER SHIFT, right, movewindow, r"
      "SUPER SHIFT, up, movewindow, u"
      "SUPER SHIFT, down, movewindow, d"

      "SUPER CTRL, left, resizeactive, -20 0"
      "SUPER CTRL, right, resizeactive, 20 0"
      "SUPER CTRL, up, resizeactive, 0 -20"
      "SUPER CTRL, down, resizeactive, 0 20"
    ];

    workspace = [
      "1, monitor:DP-2, default:true"
      "2, monitor:DP-2"
      "3, monitor:DP-2"
      "4, monitor:DP-2"
      "5, monitor:HDMI-A-1"
      "6, monitor:HDMI-A-1"
      "7, monitor:HDMI-A-1"
      "8, monitor:HDMI-A-1"
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

    animations = {
      enabled = "yes";
      bezier = [
        "snappyBezier, 0.4, 0.0, 0.2, 1.0"
        "smoothBezier, 0.25, 0.1, 0.25, 1.0"
      ];
      animation = [
        "windows, 1, 7, smoothBezier, slide"
        "windowsOut, 1, 7, snappyBezier, slide"
        "border, 1, 10, snappyBezier"
        "borderangle, 1, 100, smoothBezier, loop"
        "fade, 1, 7, smoothBezier"
      ];
    };

    monitor = [
      "DP-2,      1920x1080@165,    1920x0,   1, vrr, 1"
      "HDMI-A-1,   1920x1080@60,     0x0,      1"
    ];

    misc = {
      vfr = 1;
      vrr = 1;
    };

    exec-once = [
      "hyprpaper"
      "copyq --start-server"
      "mako"
      "waybar"
    ];
  };
}
