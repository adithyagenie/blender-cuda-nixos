# Blender with CUDA, OptiX, and DLSS for Nix

This flake provides Blender with CUDA and OptiX acceleration on `x86_64-linux`.
GitHub Actions builds the packages and publishes them to Cachix so you can install them without compiling Blender from source.

> [!NOTE]
> Blender 5.3 with DLSS uses a separate cache. See the [setup instructions](#blender-dlss).

## Choose a build

| Flake output | Blender build | Cachix cache |
| --- | --- | --- |
| `blender-with-cuda` or `blender-with-cuda-stable` | NixOS 26.05 | `adithyagenie` |
| `blender-with-cuda-unstable` | `nixos-unstable` | `adithyagenie` |
| [`blender_5_3`](#blender-dlss) | Blender 5.3.0 with DLSS viewport denoising | `blender-dlss` |

## Stable and unstable builds

Configure the binary cache:

```bash
cachix use adithyagenie

# Stable (NixOS 26.05)
nix run 'github:adithyagenie/blender-cuda-nixos#blender-with-cuda'

# Unstable
nix run 'github:adithyagenie/blender-cuda-nixos#blender-with-cuda-unstable'
```

Alternatively, add these settings to your NixOS configuration:

```nix
{
  nix.settings = {
    extra-substituters = [ "https://adithyagenie.cachix.org" ];
    extra-trusted-public-keys = [ "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc=" ];
  };
}
```

### Nix flake integration

Add this repository to your `flake.nix` inputs and choose an output from the
table. The example installs the stable build.

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
            blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda

            # Or use the unstable build.
            # blender-cuda.packages.${pkgs.stdenv.hostPlatform.system}.blender-with-cuda-unstable
          ];
        })
      ];
    };
  };
}
```

<a id="blender-dlss"></a>
## Blender 5.3 with DLSS

The `blender_5_3` output supports [DLSS Ray Reconstruction](https://projects.blender.org/blender/blender/pulls/153077) for Cycles viewport denoising.
This flake packages Blender 5.3 while the [nixpkgs update](https://github.com/NixOS/nixpkgs/pull/583448) is pending.

Configure the `blender-dlss` cache and run Blender 5.3.

```bash
cachix use blender-dlss
nix run 'github:adithyagenie/blender-cuda-nixos#blender_5_3'
```

Alternatively, add these settings to your NixOS configuration:

```nix
{
  nix.settings = {
    extra-substituters = [ "https://blender-dlss.cachix.org" ];
    extra-trusted-public-keys = [ "blender-dlss.cachix.org-1:8ihF5ekCgU4K+5sgRfvM6qz/T4AcnrtV951oL9wXm0I=" ];
  };
}
```

To install it through your NixOS flake, use `blender_5_3` in the
[flake integration example](#nix-flake-integration).

### Enable DLSS in Cycles

1. In **Preferences → System → Cycles Render Devices**, choose **CUDA** or
   **OptiX** and enable your NVIDIA GPU.
2. In **Render Properties**, set the engine to **Cycles** and the device to
   **GPU Compute**.
3. Under **Sampling → Viewport**, enable **Denoise** and select **DLSS**.

On NixOS, the launcher uses the installed NVIDIA driver and the signed DLSSD 310.9.1 library.
The `nvidia-dlss-runtime` output includes the library and its SDK license.

---

### References

The Blender 5.3 patches came from the [nixpkgs pull request](https://github.com/NixOS/nixpkgs/pull/583448).
