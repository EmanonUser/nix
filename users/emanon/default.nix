{
  lib,
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
    initialPassword = lib.mkDefault "123456";
  };

  programs.zsh.enable = true;
}
