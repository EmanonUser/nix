{ lib, pkgs, hostname, ... }:
let
  hostCa = builtins.readFile ./host_ca.pub;
  certAuthority =
    "@cert-authority \"*.home.arpa,*.emanon.dev\" "
    + lib.concatStringsSep " " (lib.take 2 (lib.splitString " " hostCa))
    + "\n";

  # Per-host public half of the identity deployed via agenix
  # (config/${hostname}/ssh/id_ed25519.age). `.pub` ships to git's allowed_signers;
  # `-cert.pub` is the host's roaming user cert, trusted by ssh-server via
  # user_ca.pub.
  pub = ../../config + "/${hostname}/ssh/id_ed25519.pub";
  cert = ../../config + "/${hostname}/ssh/id_ed25519-cert.pub";
in {
  home.file.".ssh/config" = {
    source = ./config;
    force = true;
  };

  # known_hosts must stay a REAL, writable file: ssh appends freshly-verified
  # host keys (TOFU) to it, which a managed nix-store symlink forbids. We only
  # seed the cert-authority trust anchor and leave the rest alone.
  home.activation.seedKnownHosts = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
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
