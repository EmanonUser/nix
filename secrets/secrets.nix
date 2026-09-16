let
  fern = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaTLWC5KirziNieTZw7LFPkuKDhnJKgjqs93TJVJQ1l emanon@fern";
  vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6btmu06DEv1BSicz0bD5IObx0Zj0/pZVwBShq0iRMO root@nixos-vm";
  sasurai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMerlJ+NA2avmCP0fTStNhF/7ZWTvxmGtT4aivtZ2slq emanon@sasurai";
  zoltraak = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMerlJ+NA2avmCP0fTStNhF/7ZWTvxmGtT4aivtZ2slq emanon@sasurai";
in {
  "atuin_session.age".publicKeys = [fern vm sasurai zoltraak];
  "atuin_key.age".publicKeys = [fern vm sasurai zoltraak];
}
