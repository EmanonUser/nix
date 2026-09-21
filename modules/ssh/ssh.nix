{ lib, hostname, ... }:
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
  home.file.".ssh/config".source = ./config;

  home.file.".ssh/known_hosts".text = certAuthority;

  home.file.".ssh/id_ed25519.pub".source = pub;
  home.file.".ssh/id_ed25519-cert.pub".source = cert;
}
