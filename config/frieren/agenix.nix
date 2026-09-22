{username, ...}: {
  # This host's user SSH identity, sealed to its own host key
  # (config/frieren/ssh/ssh_host_ed25519_key.age).
  #
  # For decryption this standalone home-manager host falls back on the default
  # identityPaths (~/.ssh/id_ed25519). That only works when frieren's own
  # identity key is among the age recipients (or seed ~/.ssh/id_ed25519
  # manually).
  age.secrets."user-ssh-id" = {
    file = ./ssh/id_ed25519.age;
    path = "/home/${username}/.ssh/id_ed25519";
    mode = "0600";
    symlink = false;
  };

  # Atuin auto-login credentials, shared with the NixOS hosts. Decrypted at
  # /run/agenix by default (same paths the atuin module hardcodes).
  age.secrets."atuin-key" = {
    file = ../${username}/atuin-key.age;
  };
  age.secrets."atuin-session" = {
    file = ../${username}/atuin-session.age;
  };
}