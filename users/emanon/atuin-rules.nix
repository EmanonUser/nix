let
  fern = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaTLWC5KirziNieTZw7LFPkuKDhnJKgjqs93TJVJQ1l emanon@fern";
  sasurai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEXkYpx4hIeFUlMFWZLGYV5ooNczqTLMAFabDkqEr1F sasurai ssh host key";
  zoltraak = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLNzsQ2tqJ+Ozsbj+ZqJI1EOzzLlBM1tKvv0c970MX3 zoltraak ssh host key";
  nixosVm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHyC4c7eP8+zyHgGLrtuXgNg2K0ADF4MzwOPm9qIMY5 nixos-vm host key";
  hosts = [fern sasurai zoltraak nixosVm];
in {
  "atuin-key.age".publicKeys = hosts;
  "atuin-token.age".publicKeys = hosts;
}
