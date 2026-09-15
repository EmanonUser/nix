{
  hostname,
  ...
}: {
  # git is auto-installed by programs.git.enable below.

  home.file = {
    ".ssh/allowed_signers".text = "* ${builtins.readFile ../../${hostname}/id_ed25519.pub}";
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
