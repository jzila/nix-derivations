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

  filename = "signoz-mcp-server_${platform.suffix}.${platform.ext}";

in stdenv.mkDerivation rec {
  pname = "signoz-mcp-server";
  inherit version;

  src = fetchurl {
    url = "https://github.com/SigNoz/signoz-mcp-server/releases/download/v${version}/${filename}";
    sha256 = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = "signoz-mcp-server_${platform.suffix}";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/signoz-mcp-server $out/bin/signoz-mcp-server
    runHook postInstall
  '';

  meta = with lib; {
    description = "Model Context Protocol server for SigNoz observability platform";
    homepage = "https://github.com/SigNoz/signoz-mcp-server";
    license = licenses.mit;
    platforms = builtins.attrNames platformMap;
    mainProgram = "signoz-mcp-server";
  };
}
