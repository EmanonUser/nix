{pkgs, ...}: {
  home.packages = with pkgs; [
    git
  ];

  home.file = {
    ".ssh/allowed_signers".text = "* ${builtins.readFile ../id_ed25519.pub}";
  };

  programs.git = {
    enable = true;
    userName = "Emanon";
    userEmail = "moemanon@pm.me";
    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };
}
