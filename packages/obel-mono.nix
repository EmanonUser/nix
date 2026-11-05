{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  masked ? false,
}: let
  version = "1.000";
  pname =
    if masked
    then "obel-mono-masked"
    else "obel-mono";
in
  stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://typographic.systems/download/ObelMono${if masked then "Masked" else ""}-${version}-ttf.zip";
      hash =
        if masked
        then "sha256-3+l28s2XXWZaWwdllO4sC5wPcTVPfcCbm3kmnBYZm9s="
        else "sha256-051IC0tSrIzJIhuG+Iirexm+hXSzFeNP7BQUVzHgOE0=";
    };

    nativeBuildInputs = [unzip];
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
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  }
