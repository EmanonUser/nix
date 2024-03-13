{
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        pane_frames = false;
        default_layout = "compact";
      };
    };
  };
}
