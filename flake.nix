{
  description = "Personal Nix derivations for bleeding-edge packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      versions = builtins.fromJSON (builtins.readFile ./versions.json);

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          beads = pkgs.callPackage ./pkgs/beads {
            inherit (versions.beads) version hashes;
          };

          claude-code = pkgs.callPackage ./pkgs/claude-code {
            inherit (versions.claude-code) version hashes;
          };

          default = self.packages.${system}.claude-code;
        };
      }
    ) // {
      # Overlay for use in other flakes
      overlays.default = final: prev: {
        beads = prev.callPackage ./pkgs/beads {
          inherit (versions.beads) version hashes;
        };
        claude-code = prev.callPackage ./pkgs/claude-code {
          inherit (versions.claude-code) version hashes;
        };
      };
    };
}
