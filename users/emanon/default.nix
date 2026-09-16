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

  # Passwordless sudo for the emanon user.
  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
