{
  lib,
  pkgs,
  hostname,
  ...
}: let
  hostCa = builtins.readFile ./host_ca.pub;
  certAuthority =
    "@cert-authority \"*.home.arpa,*.emanon.dev\" "
    + lib.concatStringsSep " " (lib.take 2 (lib.splitString " " hostCa))
    + "\n";

  pub = ../../configs + "/${hostname}/ssh/id_ed25519.pub";
  cert = ../../configs + "/${hostname}/ssh/id_ed25519-cert.pub";
in {
  home.file.".ssh/config" = {
    source = ./config;
    force = true;
  };

  home.activation.seedKnownHosts = lib.hm.dag.entryAfter ["linkGeneration"] ''
    f="$HOME/.ssh/known_hosts"
    ${pkgs.coreutils}/bin/install -d -m 700 "$HOME/.ssh"
    if [ -L "$f" ]; then
      rm -f "$f"
    fi
    ${pkgs.coreutils}/bin/touch "$f"
    if ! ${pkgs.gnugrep}/bin/grep -qF '@cert-authority' "$f"; then
      ${pkgs.coreutils}/bin/printf '%s' "${lib.escapeShellArg certAuthority}" >> "$f"
    fi
    ${pkgs.coreutils}/bin/chmod 600 "$f"
  '';

  home.file.".ssh/id_ed25519.pub" = {
    source = pub;
    force = true;
  };
  home.file.".ssh/id_ed25519-cert.pub" = {
    source = cert;
    force = true;
  };
}
