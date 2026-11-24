{
  hostname,
  ...
}: {
  programs.nushell = {
    enable = true;
    loadSessionVariables = true;

    settings = {
      show_banner = false;
      edit_mode = "emacs";
      show_hints = true;
      use_ansi_coloring = true;
      history.file_format = "sqlite";
      completions.external = {
        enable = true;
        max_results = 200;
      };
    };

    environmentVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
      LC_CTYPE = "en_US.UTF-8";
    };

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      ll = "ls -l";
      la = "ls -a -l";
      ip = "^ip --color=auto";
      grep = "^grep --color=auto";
      nrs = "^sudo nixos-rebuild switch --flake $\"($env.HOME)/nix/.#${hostname}\"";
      nrb = "^sudo nixos-rebuild build --flake $\"($env.HOME)/nix/.#${hostname}\"";
      nu = "nix flake update";
    };

    extraConfig = ''
      def --wrapped nr [package: string, ...args: string] {
        ^nix run $"nixpkgs#($package)" -- ...$args
      }

      $env.config = ($env.config? | default {})
      $env.config.hooks = ($env.config.hooks? | default {})
      $env.config.hooks.pre_prompt = (
        $env.config.hooks.pre_prompt?
        | default []
        | append {||
          let gitdir = (do -i { ^git rev-parse --absolute-git-dir } | complete)
          if $gitdir.exit_code != 0 {
            return
          }
          let stamp = ($gitdir.stdout | str trim | path join "nushell-autofetch")
          let due = (
            try {
              ((date now) - (ls $stamp | get 0.modified)) > 5min
            } catch {
              true
            }
          )
          if $due {
            try { touch $stamp } catch {}
            job spawn { ^git fetch --all --quiet } | ignore
          }
        }
      )
    '';
  };

  programs.starship.enableNushellIntegration = true;
  programs.zoxide.enableNushellIntegration = true;
  programs.direnv.enableNushellIntegration = true;
  programs.atuin.enableNushellIntegration = true;
}
