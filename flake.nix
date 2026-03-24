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
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          nsc = pkgs.callPackage ./pkgs/nsc {
            inherit (versions.nsc) version hashes;
          };

          devbox = pkgs.callPackage ./pkgs/devbox {
            inherit (versions.devbox) version hashes;
          };

          beads = pkgs.callPackage ./pkgs/beads {
            inherit (versions.beads) version hashes;
          };

          gh-dash = pkgs.callPackage ./pkgs/gh-dash {
            inherit (versions.gh-dash) version hashes;
          };

          signoz-mcp-server = pkgs.callPackage ./pkgs/signoz-mcp-server {
            inherit (versions.signoz-mcp-server) version hashes;
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
        nsc = prev.callPackage ./pkgs/nsc {
          inherit (versions.nsc) version hashes;
        };
        devbox = prev.callPackage ./pkgs/devbox {
          inherit (versions.devbox) version hashes;
        };
        beads = prev.callPackage ./pkgs/beads {
          inherit (versions.beads) version hashes;
        };
        gh-dash = prev.callPackage ./pkgs/gh-dash {
          inherit (versions.gh-dash) version hashes;
        };
        signoz-mcp-server = prev.callPackage ./pkgs/signoz-mcp-server {
          inherit (versions.signoz-mcp-server) version hashes;
        };
        claude-code = prev.callPackage ./pkgs/claude-code {
          inherit (versions.claude-code) version hashes;
        };
      };
    };
}
