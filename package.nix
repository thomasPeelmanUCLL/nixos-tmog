{ lib
, appimageTools
, fetchurl
}:

let
  pname = "tmog";
  version = "0.1.1"; # bump when tmog.org publishes a new beta

  src = fetchurl {
    url = "https://tmog.org/downloads/TMOG-Task-Manager-Linux-x86_64.AppImage";
    # run: nix-prefetch-url "<url>"
    # then: nix hash convert --hash-algo sha256 --to sri <result>
    hash = "sha256-0000000000000000000000000000000000000000000=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtsvg
    systemd
    libxkbcommon
    wayland
    alsa-lib
  ];

  extraInstallCommands = ''
    # Uncomment/adjust once you've checked appimageContents for a .desktop/icon:
    # install -m 444 -D ${appimageContents}/tmog.desktop $out/share/applications/tmog.desktop
    # install -m 444 -D ${appimageContents}/tmog.png $out/share/icons/hicolor/256x256/apps/tmog.png
  '';

  meta = with lib; {
    description = "Native cross-platform system monitor / task manager by Dave Plummer";
    homepage = "https://tmog.org";
    license = licenses.unfree; # closed-source, EULA bundled with the download
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
  };
}
