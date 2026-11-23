let
  fern = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaTLWC5KirziNieTZw7LFPkuKDhnJKgjqs93TJVJQ1l emanon@fern";
  sasurai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEXkYpx4hIeFUlMFWZLGYV5ooNczqTLMAFabDkqEr1F sasurai ssh host key";
  zoltraak = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLNzsQ2tqJ+Ozsbj+ZqJI1EOzzLlBM1tKvv0c970MX3 zoltraak ssh host key";
  flamme = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMT+GNTnrD1C3I9iw98zAu6c2n9RZsSiyu4ce/hV4+5s flamme ssh host key";
  flammeUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0MOnjO3PItbq9rvr7jFIEy3v+NgpbveydnjRgT8Ebg emanon@flamme";
  hosts = [fern sasurai zoltraak flamme flammeUser];
in {
  "atuin-key.age".publicKeys = hosts;
  "atuin-token.age".publicKeys = hosts;
}
