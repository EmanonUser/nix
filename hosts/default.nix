{hostName, ...}: {
  imports = [
    ./${hostName}
    ./localization.nix
  ];
}
