{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      keymap_mode = "vim-normal";
      search_mode = "daemon-fuzzy";
      daemon = {
        enabled = true;
        autostart = true;
      };
      # Auto-login: session + key files are managed via age secrets landing at
      # /run/agenix (NixOS-host and home-manager agenix both default there).
      session_path = "/run/agenix/atuin-session";
      key_path = "/run/agenix/atuin-key";
    };
  };
}
