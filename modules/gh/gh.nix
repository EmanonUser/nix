{pkgs, ...}: let
  gh = pkgs.gh;
  ghWithToken = pkgs.writeShellScriptBin "gh" ''
    if [ -z "''${GH_TOKEN:-}" ]; then
      for token in /run/agenix/gh-token "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/agenix/gh-token"; do
        if [ -r "$token" ]; then
          GH_TOKEN="$(cat "$token")"
          export GH_TOKEN
          break
        fi
      done
    fi
    exec ${gh}/bin/gh "$@"
  '';
in {
  programs.gh = {
    enable = true;
    package = ghWithToken;
    gitCredentialHelper.enable = true;
    settings.git_protocol = "ssh";
  };
}
