{pkgs, ...}: let
  gh = pkgs.gh;
  ghWithToken = pkgs.writeShellScriptBin "gh" ''
    if [ -z "''${GH_TOKEN:-}" ] && [ -r /run/agenix/gh-token ]; then
      GH_TOKEN="$(cat /run/agenix/gh-token)"
      export GH_TOKEN
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
