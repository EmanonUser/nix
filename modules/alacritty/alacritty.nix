{
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.alacritty = {
      enable = true;
    };
  };
}
