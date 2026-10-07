{
  xdg.configFile."umbriel/config.toml".text = ''
    [general]
    autostart = ["noctalia"]

    [output.HDMI-A-1]
    mode = "1920x1080@60"
    position = [0, 0]

    [output.DP-2]
    mode = "1920x1080@165"
    position = [1920, 0]
    vrr = "always"

    [input.keyboard]
    layout = "fr"
    variant = "azerty"
    numlock_toggle = true

    [appearance]
    prefer_no_csd = true
    border_width = 2
    corner_radius = 10

    [appearance.blur]
    enabled = true
    optimized = true
    passes = 3
    radius = 3
    noise = 0.02
    brightness = 0.9
    contrast = 0.9
    saturation = 1.1

    [[window_rule]]
    blur = true
    blur_optimized = true

    [[window_rule]]
    match.app_id = "^dev.noctalia.Noctalia$"
    default_floating = true
    default_floating_size_px = { width = 1020, height = 900 }

    [[layer_rule]]
    match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$"
    blur = true
    blur_ignore_alpha = 0.5
    blur_popups = true
    blur_optimized = false

    [keybinds]
    "Mod+Space" = "spawn:noctalia msg panel-toggle launcher"
    "Mod+S" = "spawn:noctalia msg panel-toggle control-center"
    "Mod+Comma" = "spawn:noctalia msg settings-toggle"
    "Alt+Tab" = "spawn:noctalia msg window-switcher hold"
    "Mod+Shift+A" = "spawn:noctalia msg screenshot-annotate"
    "Mod+Ctrl+A" = "spawn:noctalia msg annotate"
    "XF86AudioRaiseVolume" = "spawn:noctalia msg volume-up"
    "XF86AudioLowerVolume" = "spawn:noctalia msg volume-down"
    "XF86AudioMute" = "spawn:noctalia msg volume-mute"
    "XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up"
    "XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down"
  '';
}
