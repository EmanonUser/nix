{
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.starship = {
      enable = true;
    };
  };
}
