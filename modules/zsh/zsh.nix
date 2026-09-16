{
  pkgs,
  config,
  ...
}: {
  # zsh is auto-installed by programs.zsh.enable below.
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.opencode/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SYSTEMD_EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      cd = "z";
      ls = "ls --color";
      ll = "ls --color --group-directories-first -lh";
      la = "ls --color --group-directories-first -Alh --ignore='[^.]*'";
      ip = "ip --color=auto";
      grep = "grep --color";
    };

    # Mirrors the raw ~/.zshenv (cargo + local bin paths, editors)
    envExtra = ''
      export PATH=$PATH:"$HOME/.local/bin"
      export PATH=$PATH:"$HOME/.cargo/bin"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      export EDITOR="nvim"
      export VISUAL="nvim"
      export SYSTEMD_EDITOR="nvim"
      export MANPAGER="nvim +Man!"
    '';

    initContent = ''
      # completion styles from the original .zshrc
      zstyle ':completion:*' completer _expand _complete _ignored _approximate
      zstyle ':completion:*' list-colors '''
      zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
      zstyle ':completion:*' matcher-list ''' ''' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'l:|=* r:|=*'
      zstyle ':completion:*' menu select=1
      zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
      zstyle :compinstall filename '${config.home.homeDirectory}/.config/zsh/.zshrc'

      # word movement
      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      bindkey  "^[[3~"  delete-char
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      autoload edit-command-line
      zle -N edit-command-line
      bindkey '^Xe' edit-command-line

      # git auto-fetch (adapted from the dotfiles)
      source ${./git_auto_fetch.zsh}

      export LC_CTYPE=en_US.UTF-8
    '';
  };
}
