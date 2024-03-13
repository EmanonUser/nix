{
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
