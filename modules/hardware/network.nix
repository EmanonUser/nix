{ hostName, ... }:{
  networking.hostName = "${hostName}";
  networking.networkmanager.enable = true;
}
