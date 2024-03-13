{
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = {
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

      initExtra = ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        autoload edit-command-line
        zle -N edit-command-line
        bindkey '^Xe' edit-command-line
      '';
    };
  };
}
