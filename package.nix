{ lib
, appimageTools
, fetchurl
}:

let
  pname = "tmog";
  version = "0.1.1"; # bump when tmog.org publishes a new beta

  src = fetchurl {
    url = "https://tmog.org/downloads/TMOG-Task-Manager-Linux-x86_64.AppImage";
    hash = "sha256-C68GRpfWdzKADWMVZEaX7BU7jlBqUXMwTIXzMLLb5tI=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
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
    libva
    libvdpau
    mesa
    libglvnd
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/com.tmog.taskmanager.desktop \
      $out/share/applications/com.tmog.taskmanager.desktop
    install -m 444 -D ${appimageContents}/tmog-task-manager.png \
      $out/share/icons/hicolor/256x256/apps/tmog-task-manager.png
    substituteInPlace $out/share/applications/com.tmog.taskmanager.desktop \
      --replace-fail 'Exec=tmog-task-manager' "Exec=$out/bin/${pname}"
  '';

  meta = with lib; {
    description = "Native cross-platform system monitor / task manager by Dave Plummer";
    homepage = "https://tmog.org";
    license = licenses.unfree; # closed-source, EULA bundled with the download
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "tmog";
    maintainers = [ ];
  };
}
