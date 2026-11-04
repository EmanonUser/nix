{pkgs, ...}: let
  # Obel Mono 1.000 (SIL OFL 1.1) ships only as a zip. The ttf builds bundle
  # variable Roman/Italic and the 18 static instances; install the static ones
  # so weight selection works in terminals and Qt apps that do not handle
  # variable fonts. "Masked" is the same family with the ss01 secret-masking
  # feature on by default.
  version = "1.000";

  obel-mono = {
    masked ? false,
  }: let
    pname =
      if masked
      then "obel-mono-masked"
      else "obel-mono";
  in
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;

      src = pkgs.fetchurl {
        url = "https://typographic.systems/download/ObelMono${if masked then "Masked" else ""}-${version}-ttf.zip";
        hash =
          if masked
          then "sha256-3+l28s2XXWZaWwdllO4sC5wPcTVPfcCbm3kmnBYZm9s="
          else "sha256-051IC0tSrIzJIhuG+Iirexm+hXSzFeNP7BQUVzHgOE0=";
      };

      nativeBuildInputs = [pkgs.unzip];
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        install -Dm644 -t $out/share/fonts/truetype/${pname} static/*.ttf
        install -Dm644 -t $out/share/doc/${pname} AUTHORS.txt OFL.txt README.txt
        runHook postInstall
      '';

      meta = {
        description =
          if masked
          then "Obel Mono Masked, the secret-masking build of the Obel Mono typeface"
          else "Obel Mono, a variable monospace typeface with nine weights and italics";
        homepage = "https://typographic.systems/obel-mono";
        license = pkgs.lib.licenses.ofl;
        platforms = pkgs.lib.platforms.all;
      };
    };
in {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    (obel-mono {})
    (obel-mono {masked = true;})
  ];
}
