{hostname, lib, ...}: let
  # git is auto-installed by programs.git.enable below.
  signingKey = ../../config/${hostname}/id_ed25519.pub;
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
