{
  config,
  pkgs,
  ...
}: {
  home.username = "emanon";
  home.homeDirectory = "/home/emanon";

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      ls = "ls --color";
      ll = "ls --color --group-directories-first -lh";
      la = "ls --color --group-directories-first -Alh --ignore='[^.]*'";
      ip = "ip --color=auto";
      grep = "grep --color";
    };
  };

  programs.starship.enable = true;
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];
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

  programs.alacritty = {
    enable = true;
  };

  home.packages = with pkgs; [
    alacritty
    starship
    htop
  ];

  home.file = {
    ".ssh/allowed_signers".text = "* ${builtins.readFile /home/emanon/.ssh/id_ed25519.pub}";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
