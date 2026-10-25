{
  xdg.configFile."noctalia/config.toml".text = ''
    [bar.main]
    end = ["media", "tray", "notifications", "clipboard", "volume", "brightness", "control-center", "session"]
  '';

  xdg.configFile."autostart/noctalia.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Noctalia
    Comment=Noctalia desktop shell
    Exec=noctalia --daemon
    OnlyShowIn=KDE;
    X-GNOME-Autostart-enabled=true
    NoDisplay=true
  '';
}
