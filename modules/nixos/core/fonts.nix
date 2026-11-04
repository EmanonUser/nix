{pkgs, ...}: let
  # Obel Mono 1.000 (SIL OFL 1.1) ships only as a zip. The ttf build bundles
  # the variable Roman/Italic and the 18 static instances; install the static
  # ones so weight selection works in terminals and Qt apps that do not handle
  # variable fonts.
  version = "1.000";

  obel-mono = pkgs.stdenvNoCC.mkDerivation {
    pname = "obel-mono";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://typographic.systems/download/ObelMono-${version}-ttf.zip";
      hash = "sha256-051IC0tSrIzJIhuG+Iirexm+hXSzFeNP7BQUVzHgOE0=";
    };

    nativeBuildInputs = [pkgs.unzip];
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/fonts/truetype/obel-mono static/*.ttf
      install -Dm644 -t $out/share/doc/obel-mono AUTHORS.txt OFL.txt README.txt
      runHook postInstall
    '';

    meta = {
      description = "Obel Mono, a variable monospace typeface with nine weights and italics";
      homepage = "https://typographic.systems/obel-mono";
      license = pkgs.lib.licenses.ofl;
      platforms = pkgs.lib.platforms.all;
    };
  };
in {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    obel-mono
  ];
}
