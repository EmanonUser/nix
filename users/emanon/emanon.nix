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
      hashedPasswordFile = config.age.secrets.user-password.path;
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
