{
  config,
  lib,
  pkgs,
  ...
}: let
  zellijCompletion = pkgs.runCommand "zellij-zsh-completion" {} ''
    ${lib.getExe pkgs.zellij} setup --generate-completion zsh > $out
  '';
in {
  home.packages = with pkgs; [
    zellij
  ];

  home.file.".config/zellij/config.kdl" = {
    source = ./config.kdl;
  };

  home.file."${config.xdg.configHome}/zsh/completions/_zellij".source = zellijCompletion;

  programs.zsh.initContent = lib.mkMerge [
    (lib.mkOrder 550 ''
      fpath=("${config.xdg.configHome}/zsh/completions" $fpath)
    '')
    ''
      _zellij_sessions() {
        local -a sessions
        sessions=(''${(f)"$(command zellij list-sessions --short 2>/dev/null)"})
        _describe -t sessions 'zellij session' sessions
      }

      _zellij_complete() {
        if [[ "$words[2]" == attach && $CURRENT -eq 3 && "$PREFIX" != -* ]]; then
          _zellij_sessions
        else
          _zellij "$@"
        fi
      }

      compdef _zellij_complete zellij
    ''
  ];
}
