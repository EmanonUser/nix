{ lib, ... }:
let
  hostCa = builtins.readFile ./host_ca.pub;
  certAuthority =
    "@cert-authority \"*.home.arpa,*.emanon.dev\" "
    + lib.concatStringsSep " " (lib.take 2 (lib.splitString " " hostCa))
    + "\n";
in {
  home.file.".ssh/config".source = ./config;

  home.file.".ssh/known_hosts".text = certAuthority;
}
