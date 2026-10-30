{
  lib,
  username,
  ...
}: {
  # This host's user SSH identity, sealed to its own host key
  # (configs/fern/ssh/ssh_host_ed25519_key.age).
  #
  # For decryption this standalone home-manager host falls back on the default
  # identityPaths (~/.ssh/id_ed25519). That only works when fern's own
  # identity key is among the age recipients (or seed ~/.ssh/id_ed25519
  # manually).
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

  # Atuin sync credentials, decrypted by the home-manager agenix service to
  # $XDG_RUNTIME_DIR/agenix; modules/atuin/atuin.nix seeds the token from there.
  age.secrets."atuin-key" = lib.mkIf (builtins.pathExists (../../users + "/${username}/atuin-key.age")) {
    file = ../../users + "/${username}/atuin-key.age";
    mode = "0400";
  };

  age.secrets."atuin-token" = lib.mkIf (builtins.pathExists (../../users + "/${username}/atuin-token.age")) {
    file = ../../users + "/${username}/atuin-token.age";
    mode = "0400";
  };
}
