{
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    (pkgs.stdenv.mkDerivation {
      pname = "grabit";
      version = "0.7.0";

      src = pkgs.fetchFromGitHub {
        owner = "Creationsss";
        repo = "grabit";
        rev = "0.7.0";
        hash = "sha256-WAFY4E0F2GwXYqmuxoO3S8R/OsoiyyZTrUkMbmmW2dw=";
      };

      nativeBuildInputs = with pkgs; [
        pkg-config
        wayland-scanner
        makeWrapper
      ];

      buildInputs = with pkgs; [
        json_c
        curl
        file
        wayland
        libpng
        libjpeg
        libwebp
        cairo
        libxkbcommon
        pipewire
        dbus
      ];

      makeFlags = ["PREFIX=$(out)"];

      # Match the runtime wrapping from grabit's own flake: recording (ffmpeg),
      # OCR (tesseract) and translation (translate-shell).
      postFixup = ''
        wrapProgram $out/bin/grabit \
          --prefix PATH : ${lib.makeBinPath (with pkgs; [ffmpeg-headless tesseract translate-shell])}
      '';

      meta = with lib; {
        description = "Screenshot, screen-recording, OCR and uploader for wlroots compositors (niri/sway/hyprland/river)";
        homepage = "https://heliopolis.live/creations/grabit";
        license = licenses.agpl3Plus;
        platforms = platforms.linux;
        mainProgram = "grabit";
      };
    })
  ];
}
