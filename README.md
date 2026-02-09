# nix-derivations

Personal Nix derivations for bleeding-edge packages.

## Available Packages

| Package | Description |
|---------|-------------|
| `claude-code` | Anthropic's agentic coding tool |
| `beads` | Distributed, git-backed graph issue tracker for AI coding agents |

## Supported Platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## Usage

### In a flake.nix

#### Using the overlay

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-derivations.url = "github:jzila/nix-derivations";
  };

  outputs = { self, nixpkgs, nix-derivations, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nix-derivations.overlays.default ];
        config.allowUnfree = true;  # Required for claude-code
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.claude-code
          pkgs.beads
        ];
      };
    };
}
```

#### Referencing packages directly

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-derivations.url = "github:jzila/nix-derivations";
  };

  outputs = { self, nixpkgs, nix-derivations, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          nix-derivations.packages.${system}.claude-code
          nix-derivations.packages.${system}.beads
        ];
      };
    };
}
```

### In devenv

#### devenv.yaml

```yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
  nix-derivations:
    url: github:jzila/nix-derivations

allowUnfree: true  # Required for claude-code
```

#### devenv.nix

```nix
{ inputs, pkgs, ... }:

{
  nixpkgs.overlays = [ inputs.nix-derivations.overlays.default ];

  packages = [
    pkgs.claude-code
    pkgs.beads
  ];
}
```

### One-off usage with nix run

```bash
# Run claude-code directly
nix run github:jzila/nix-derivations#claude-code

# Run beads
nix run github:jzila/nix-derivations#beads
```

## Unfree Packages

`claude-code` is an unfree package. You may need to allow unfree packages in your configuration:

```nix
# In your flake.nix
pkgs = import nixpkgs {
  inherit system;
  config.allowUnfree = true;
};
```

Or set the environment variable:

```bash
export NIXPKGS_ALLOW_UNFREE=1
```
