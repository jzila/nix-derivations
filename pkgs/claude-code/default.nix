{ lib
, stdenvNoCC
, stdenv
, fetchurl
, patchelf
, makeWrapper
, version
, hashes
}:

let
  gcsBase = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";

  platformMap = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };

  platform = platformMap.${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");

in stdenvNoCC.mkDerivation rec {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    url = "${gcsBase}/${version}/${platform}/claude";
    hash = hashes.${stdenvNoCC.hostPlatform.system};
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenvNoCC.isLinux [ patchelf ];

  # Bun binaries have JS appended after ELF - autoPatchelfHook corrupts this.
  # Only patch the interpreter, don't modify rpath or strip.
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/.claude-unwrapped
  '' + lib.optionalString stdenvNoCC.isLinux ''
    patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" $out/bin/.claude-unwrapped
  '' + ''
    makeWrapper $out/bin/.claude-unwrapped $out/bin/claude \
      --set DISABLE_INSTALLATION_CHECKS 1
    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code - Anthropic's agentic coding tool";
    homepage = "https://code.claude.com";
    license = licenses.unfree;
    platforms = builtins.attrNames platformMap;
    mainProgram = "claude";
  };
}
