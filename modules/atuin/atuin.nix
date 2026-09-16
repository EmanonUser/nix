{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      keymap_mode = "vim-normal";
      key_path = "/run/agenix/atuin_key";
      session_path = "/run/agenix/atuin_session";
    };
  };
}
