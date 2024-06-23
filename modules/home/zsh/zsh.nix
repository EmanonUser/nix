{pkgs, ...}: let
  git-auto-fetch = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/cb86d378f287f1731cc6ad907f6248e35b52dc25/plugins/git-auto-fetch/git-auto-fetch.plugin.zsh";
    hash = "sha256-RxAF8YeKNny+nRz7aicQi3hEzYUfjMlJ+hmM7nH8YSY=";
  };
in {
  home.packages = with pkgs; [
    zsh
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
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

    initExtra = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      autoload edit-command-line
      zle -N edit-command-line
      bindkey '^Xe' edit-command-line
      source ${git-auto-fetch}
      export LC_CTYPE=en_US.UTF-8
    '';
  };
}
