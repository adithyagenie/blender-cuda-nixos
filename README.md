# Blender with CUDA Support (NixOS 25.11)

This repository provides a Nix flake to build Blender with CUDA acceleration using NixOS 25.11 packages.
Since blender with CUDA support is a pain to compile from source, I use GHA to build the package and upload it to Cachix.

### Binary Cache (Cachix)

To avoid compiling Blender from source, you can use the pre-built binaries from Cachix:

```bash
cachix use adithyagenie
```

Alternatively, add the following to your Nix configuration:

```nix
{
  nix.settings = {
    substituters = [ "https://adithyagenie.cachix.org" ];
    trusted-public-keys = [ "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc=" ];
  };
}
```

### Usage

Available package outputs:

- `blender-with-cuda` / `blender-with-cuda-stable`: stable Blender from NixOS 25.11
- `blender-with-cuda-unstable`: Blender from `nixos-unstable`

#### Nix Flake integration

Add this repository to your `flake.nix` inputs:

```nix
{
  inputs = {
    blender-cuda.url = "github:adithyagenie/blender-cuda-nixos";
  };

  outputs = { self, nixpkgs, blender-cuda, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            blender-cuda.packages.${pkgs.system}.blender-with-cuda
            # Or use the unstable package:
            # blender-cuda.packages.${pkgs.system}.blender-with-cuda-unstable
          ];
        })
      ];
    };
  };
}
```

#### CLI Usage

```bash
# Run directly
nix run github:adithyagenie/blender-cuda-nixos#blender-with-cuda

# Run unstable
nix run github:adithyagenie/blender-cuda-nixos#blender-with-cuda-unstable

# Build locally
nix build github:adithyagenie/blender-cuda-nixos#blender-with-cuda

# Build unstable locally
nix build github:adithyagenie/blender-cuda-nixos#blender-with-cuda-unstable
```
