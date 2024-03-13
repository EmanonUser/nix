{
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = ["--disable-up-arrow"];
    };
  };
}
