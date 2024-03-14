{
  home.file.".ssh/config".text = ''
    Host s1
      Hostname s1.home.arpa
      Port 22
      KexAlgorithms +diffie-hellman-group1-sha1
      PubkeyAcceptedAlgorithms +ssh-rsa
      HostkeyAlgorithms +ssh-rsa
  '';
}
