{pkgs, ...}: {
  home.packages = with pkgs; [
    hyprpaper
    hyprpicker
    xdg-desktop-portal-hyprland
    copyq
    mako
  ];

  wayland.windowManager.hyprland.enable = true;
  #wayland.windowManager.hyprland.extraConfig = ''
  #  monitor = DP-2,      1920x1080@165,    1920x0,   1, vrr, 1
  #  monitor = HDMI-A-1,   1920x1080@60,     0x0,      1

  #  $mod = SUPER

  #  bind = $mod, a, exec, alacritty
  #  bind = $mod, z, exec, wofi --show drun
  #  bind = SUPER_SHIFT, s, exec, grimblast copysave area
  #  bind = ,Print, exec, grimblast copysave active

  #  bind = $mod, left, movefocus,l
  #  bind = $mod, right, movefocus,r
  #  bind = $mod, up, movefocus,u
  #  bind = $mod, down, movefocus,d
  #  bind = $mod, g, togglegroup
  #  bind = $mod, tab, changegroupactive
  #  bind = $mod, f, fullscreen,
  #  bind = $mod, c, centerwindow,
  #  bind = $mod, 0, exit,
  #  bind = $mod, q, killactive,
  #  bind = $mod, s, togglefloating,
  #  bind = $mod, p, pseudo,

  #  bindel = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_SINK@ 5%+
  #  bindel = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_SINK@ 5%-
  #  bindel = ,XF86AudioMute,exec,wpctl set-mute @DEFAULT_SINK@ toggle

  #  exec-once = copyq --start-server
  #  exec-once = mako

  #  input {
  #    kb_layout = fr
  #    follow_mouse = 1
  #    sensitivity = 0
  #    mouse_refocus = false
  #    force_no_accel = 1
  #  }

  #  misc {
  #    vrr = 1
  #  }

  #  $workspace_1 = Alpha
  #  $workspace_2 = Bravo
  #  $workspace_3 = Charlie
  #  $workspace_4 = Delta
  #  $workspace_5 = Echo
  #  $workspace_6 = Foxtrot
  #  $workspace_7 = Golf
  #  $workspace_8 = Hotel

  #  workspace=name:$workspace_1,monitor:DP-2
  #  workspace=name:$workspace_2,monitor:DP-2
  #  workspace=name:$workspace_3,monitor:DP-2
  #  workspace=name:$workspace_4,monitor:DP-2
  #  workspace=name:$workspace_4,monitor:HDMI-A-1
  #  workspace=name:$workspace_5,monitor:HDMI-A-1
  #  workspace=name:$workspace_6,monitor:HDMI-A-1
  #  workspace=name:$workspace_7,monitor:HDMI-A-1
  #  workspace=name:$workspace_8,monitor:HDMI-A-1

  #  bind = $mod SHIFT, ampersand, movetoworkspace, 1
  #  bind = $mod SHIFT, eacute, movetoworkspace, 2
  #  bind = $mod SHIFT, quotedbl, movetoworkspace, 3
  #  bind = $mod SHIFT, apostrophe, movetoworkspace, 4
  #  bind = $mod SHIFT, parenleft, movetoworkspace, 5"
  #  bind = $mod SHIFT, egrave, movetoworkspace, 6"
  #  bind = $mod SHIFT, minus, movetoworkspace, 7"
  #  bind = $mod SHIFT, underscore, movetoworkspace, 8"

  #  bind = $mod, ampersand, workspace, 1
  #  bind = $mod, eacute, workspace, 2
  #  bind = $mod, quotedbl, workspace, 3
  #  bind = $mod, apostrophe, workspace, 4
  #  bind = $mod, parenleft, workspace, 5"
  #  bind = $mod, egrave, workspace, 6"
  #  bind = $mod, minus, workspace, 7"
  #  bind = $mod, underscore, workspace, 8"
  #  bind = $mod, ccedilla, workspace, 9"
  #  bind = $mod, agrave, workspace, 10"

  #  animations {
  #    enabled = yes
  #    bezier = snappyBezier, 0.4, 0.0, 0.2, 1.0
  #    bezier = smoothBezier, 0.25, 0.1, 0.25, 1.0
  #    animation = windows, 1, 7, smoothBezier, slide
  #    animation = windowsOut, 1, 7, snappyBezier, slide
  #    animation = border, 1, 10, snappyBezier
  #    animation = borderangle, 1, 100, smoothBezier, loop
  #    animation = fade, 1, 7, smoothBezier
  #  }

  #'';

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
      "SUPER_SHIFT, s, exec, grimblast copysave area"
      ", Print, exec, grimblast copysave active"
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
      vrr = 1;
    };

    exec-once = [
      "copyq --start-server"
      "mako"
    ];
  };
}
