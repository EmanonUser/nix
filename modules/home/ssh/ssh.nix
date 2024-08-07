{
  home.file.".ssh/config".text = ''
    Host sasurai
      User emanon
      Port 22
      Hostname sasurai.home.arpa
      IdentitiesOnly yes
      IdentityFile /home/emanon/.ssh/id_ed25519
      CertificateFile /home/emanon/.ssh/id_ed25519-cert.pub
      Controlmaster auto
      Controlpath ~/.ssh/ssh-%r@%h:%p.sock
      ControlPersist 900

    Host frieren
      User emanon
      Port 22
      Hostname frieren.home.arpa
      IdentitiesOnly yes
      IdentityFile /home/emanon/.ssh/id_ed25519
      CertificateFile /home/emanon/.ssh/id_ed25519-cert.pub
      Controlmaster auto
      Controlpath ~/.ssh/ssh-%r@%h:%p.sock
      ControlPersist 900

    Host vyos
      User emanon
      Port 22
      Hostname vyos.home.arpa
      IdentitiesOnly yes
      IdentityFile /home/emanon/.ssh/id_ed25519
      CertificateFile /home/emanon/.ssh/id_ed25519-cert.pub
      Controlmaster auto
      Controlpath ~/.ssh/ssh-%r@%h:%p.sock
      ControlPersist 900

    Host s1
      User emanon
      Port 22
      Hostname s1.home.arpa
      KexAlgorithms +diffie-hellman-group1-sha1
      PubkeyAcceptedAlgorithms +ssh-rsa
      HostkeyAlgorithms +ssh-rsa

    Host ubnt
      User emanon
      Port 22
      Hostname ubnt.home.arpa

    Host ctrlf
      Hostname ctrl-f.io
      User ctrlf
      Controlmaster auto
      Controlpath ~/.ssh/ssh-%r@%h:%p.sock
      ControlPersist 900
  '';
}
