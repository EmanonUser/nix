{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghostty;

  # Ghostty's only renderer is OpenGL and it requires >= 4.3. On machines whose
  # GPU tops out below that (e.g. zoltraak's Intel Sandy Bridge / NVIDIA Fermi),
  # force Mesa's llvmpipe software renderer (OpenGL 4.6) so the surface can init.
  ghostty =
    if cfg.softwareRendering
    then
      pkgs.symlinkJoin {
        name = "ghostty";
        paths = [pkgs.ghostty];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/ghostty \
            --set LIBGL_ALWAYS_SOFTWARE 1 \
            --set MESA_LOADER_DRIVER_OVERRIDE llvmpipe
        '';
      }
    else pkgs.ghostty;
in {
  options.ghostty.softwareRendering = lib.mkEnableOption "software OpenGL (llvmpipe) for Ghostty on GPUs below OpenGL 4.3";

  config = {
    home.packages = [ghostty];

    home.file.".config/ghostty/config" = {
      source = ./config;
    };
  };
}
