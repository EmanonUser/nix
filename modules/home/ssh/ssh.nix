{
  home.file.".ssh/config".text = ''
    User emanon
    Port 22
    Host s1
      Hostname s1.home.arpa
      KexAlgorithms +diffie-hellman-group1-sha1
      PubkeyAcceptedAlgorithms +ssh-rsa
      HostkeyAlgorithms +ssh-rsa

    Host s1
      Hostname r1.home.arpa

    Host sasurai
      Hostname sasurai.home.arpa

    Host frieren
      Hostname frieren.home.arpa

    Host ubnt01
      Hostname ubnt01.home.arpa

    Host ubnt02
      Hostname ubnt02.home.arpa


    Host ctrlf
      Hostname ctrl-f.io
      User ctrlf
  '';
}
