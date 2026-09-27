{
  lib,
  pkgs,
  config,
  username,
  vm ? false,
  ...
}: {
  # Password comes from the shared age secret (config/password.age). Users are
  # immutable so the hash is enforced on every activation; change the password
  # by re-encrypting the age file, not with `passwd`. Throwaway *-vm twins stay
  # mutable and keep their "vmtest" initial password (their VM host key can't
  # decrypt the secret).
  users.mutableUsers = vm;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
  } // lib.optionalAttrs (!vm) {
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
