{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, version
, hashes
}:

let
  platformMap = {
    x86_64-linux = { suffix = "linux_amd64"; ext = "tar.gz"; };
    aarch64-linux = { suffix = "linux_arm64"; ext = "tar.gz"; };
    x86_64-darwin = { suffix = "darwin_amd64"; ext = "tar.gz"; };
    aarch64-darwin = { suffix = "darwin_arm64"; ext = "tar.gz"; };
  };

  platform = platformMap.${stdenv.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  filename = "beads_${version}_${platform.suffix}.${platform.ext}";

in stdenv.mkDerivation rec {
  pname = "beads";
  inherit version;

  src = fetchurl {
    url = "https://github.com/steveyegge/beads/releases/download/v${version}/${filename}";
    sha256 = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bd $out/bin/bd
    runHook postInstall
  '';

  meta = with lib; {
    description = "Distributed, git-backed graph issue tracker for AI coding agents";
    homepage = "https://github.com/steveyegge/beads";
    license = licenses.asl20;
    platforms = builtins.attrNames platformMap;
    mainProgram = "bd";
  };
}
