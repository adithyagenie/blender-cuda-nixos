# Blender with CUDA Support (NixOS 26.05)

This repository provides a Nix flake to build Blender with CUDA acceleration using NixOS 26.05 packages.
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

- `blender-with-cuda` / `blender-with-cuda-stable`: stable Blender from NixOS 26.05
- `blender-with-cuda-unstable`: Blender from `nixos-unstable`
- `blender_5_3`: Blender 5.3.0 with CUDA and native DLSS Ray Reconstruction
- `nvidia-dlss-runtime`: signed NVIDIA Ray Reconstruction library and its SDK license

#### Blender 5.3 with DLSS

On x86_64 Linux, configure the dedicated binary cache before running the
`blender-5.3` branch:

```bash
cachix use blender-dlss
nix run --max-jobs 0 github:adithyagenie/blender-cuda-nixos/blender-5.3#blender_5_3
```

DLSS Ray Reconstruction needs a supported NVIDIA RTX GPU and driver. In
Cycles, select the GPU for rendering and choose DLSS for viewport denoising.
On NixOS, the launcher uses the installed NVIDIA driver and the signed DLSSD
`310.9.1` library from NVIDIA's GitHub SDK. The `nvidia-dlss-runtime` package
includes the SDK license.

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
