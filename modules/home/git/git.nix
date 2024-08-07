{
  pkgs,
  hostname,
  ...
}: {
  home.packages = with pkgs; [
    git
  ];

  home.file = {
    ".ssh/allowed_signers".text = "* ${builtins.readFile ../../${hostname}/id_ed25519.pub}";
  };

  programs.git = {
    enable = true;
    userName = "Emanon";
    userEmail = "moemanon@pm.me";
    extraConfig = {
      color.ui = "auto";
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      init.defaultBranch = "main";
      pull.rebase = "true";
    };
  };
}
