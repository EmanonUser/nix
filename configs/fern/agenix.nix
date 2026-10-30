{
  lib,
  username,
  ...
}: {
  age.secrets."user-ssh-id" = {
    file = ./ssh/id_ed25519.age;
    path = "/home/${username}/.ssh/id_ed25519";
    mode = "0600";
    symlink = false;
  };

  age.secrets."gh-token" = {
    file = ../../users + "/${username}/gh-token.age";
    mode = "0400";
  };

  age.secrets."atuin-key" = lib.mkIf (builtins.pathExists (../../users + "/${username}/atuin-key.age")) {
    file = ../../users + "/${username}/atuin-key.age";
    mode = "0400";
  };

  age.secrets."atuin-token" = lib.mkIf (builtins.pathExists (../../users + "/${username}/atuin-token.age")) {
    file = ../../users + "/${username}/atuin-token.age";
    mode = "0400";
  };
}
