{
  lib,
  pkgs,
  config,
  username,
  vm ? false,
  ...
}: {
  users.mutableUsers = vm;

  users.users.${username} =
    {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = ["wheel"];
    }
    // lib.optionalAttrs (!vm) {
      hashedPassword = "!";
    };

  programs.zsh.enable = true;
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
