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

  xdg.dataFile."kglobalaccel/noctalia-launcher.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Noctalia Launcher
    Comment=Toggle the Noctalia application launcher
    Exec=noctalia msg panel-toggle launcher
    Icon=noctalia
    Terminal=false
    X-KDE-Shortcuts=Alt
  '';
}
