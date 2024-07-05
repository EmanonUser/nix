{
  home.file.".ssh/config".text = ''
    Host sasurai
      User emanon
      Port 22
      Hostname sasurai.home.arpa
      IdentitiesOnly yes
      IdentityFile /home/emanon/.ssh/id_ed25519
      CertificateFile /home/emanon/.ssh/id_ed25519-cert.pub

    Host frieren
      User emanon
      Port 22
      Hostname frieren.home.arpa
      IdentitiesOnly yes
      IdentityFile /home/emanon/.ssh/id_ed25519
      CertificateFile /home/emanon/.ssh/id_ed25519-cert.pub

    Host r1
      User emanon
      Port 22
      Hostname frieren.home.arpa
      IdentitiesOnly yes
      IdentityFile /home/emanon/.ssh/id_ed25519
      CertificateFile /home/emanon/.ssh/id_ed25519-cert.pub

    Host s1
      User emanon
      Port 22
      Hostname s1.home.arpa
      KexAlgorithms +diffie-hellman-group1-sha1
      PubkeyAcceptedAlgorithms +ssh-rsa
      HostkeyAlgorithms +ssh-rsa

    Host ubnt01
      User emanon
      Port 22
      Hostname ubnt01.home.arpa

    Host ubnt02
      User emanon
      Port 22
      Hostname ubnt02.home.arpa

    Host ctrlf
      Hostname ctrl-f.io
      User ctrlf
  '';
}
