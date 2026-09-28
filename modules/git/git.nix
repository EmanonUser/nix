{lib, hostname, ...}: let
  # host's identity deployed via agenix (configs/${hostname}/ssh/id_ed25519.age) is
  # the canonical signing key on every host.
  signingKey = ../../configs + "/${hostname}/ssh/id_ed25519.pub";
in {
  home.file = lib.optionalAttrs (builtins.pathExists signingKey) {
    ".ssh/allowed_signers".text = "* ${builtins.readFile signingKey}";
  };

  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Emanon";
        email = "moemanon@pm.me";
      };
      color.ui = "auto";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      init.defaultBranch = "main";
      pull.rebase = "true";
      rerere.enabled = true;
    };
  };
}
