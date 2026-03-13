{ lib
, stdenvNoCC
, fetchurl
, version
, hashes
}:

let
  platformMap = {
    x86_64-linux = { suffix = "linux-amd64"; };
    aarch64-linux = { suffix = "linux-arm64"; };
    x86_64-darwin = { suffix = "darwin-amd64"; };
    aarch64-darwin = { suffix = "darwin-arm64"; };
  };

  platform = platformMap.${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");

  filename = "gh-dash_v${version}_${platform.suffix}";

in stdenvNoCC.mkDerivation rec {
  pname = "gh-dash";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dlvhdr/gh-dash/releases/download/v${version}/${filename}";
    sha256 = hashes.${stdenvNoCC.hostPlatform.system};
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/gh-dash
    runHook postInstall
  '';

  meta = with lib; {
    description = "A beautiful CLI dashboard for GitHub";
    homepage = "https://github.com/dlvhdr/gh-dash";
    license = licenses.mit;
    platforms = builtins.attrNames platformMap;
    mainProgram = "gh-dash";
  };
}
