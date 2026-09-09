{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, qt6
, systemd
}:

stdenv.mkDerivation rec {
  pname = "tmog";
  version = "0.1.1"; # bump when tmog.org publishes a new build

  src = fetchurl {
    url = "https://tmog.org/downloads/TMOG-Task-Manager-Linux-x86_64.tar.gz?v=${version}-free";
    # run `nix-prefetch-url <url>` (or nix store prefetch-file) to get the real hash
    hash = "sha256-0000000000000000000000000000000000000000000=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib   # provides libstdc++/libgcc_s, matches AUR's gcc-libs
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtsvg
    systemd            # libudev, etc.
  ];

  # The tarball is likely a flat dir with the binary + Qt plugin folders.
  # Adjust these paths once you've actually inspected `tar tzf` output.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/tmog
    cp -r . $out/share/tmog
    ln -s $out/share/tmog/TMOG $out/bin/tmog
    runHook postInstall
  '';

  meta = with lib; {
    description = "Native cross-platform system monitor / task manager by Dave Plummer";
    homepage = "https://tmog.org";
    license = licenses.unfree; # closed-source, EULA bundled with the download
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = [ ]; # add yourself here
  };
}
