{
  description = "Blender with CUDA";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable-pkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };
  };

  outputs = inputs @ {self, nixpkgs, unstable-pkgs, flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [];

      systems = ["x86_64-linux"];

      perSystem = { system, pkgs, ... }: let
        nixpkgsConfig = {
          allowUnfree = true;
          cudaSupport = true;
        };
        unstablePkgsForSystem = import unstable-pkgs {
          inherit system;
          config = nixpkgsConfig;
        };
        blender53Pkgs = unstablePkgsForSystem.extend (import ./blender/dependency-overrides.nix);
        blender53 = blender53Pkgs.callPackage ./blender/package.nix {
          cudaSupport = true;
          dlss = blender53Pkgs.callPackage ./deps/dlss/package.nix { };
          jolt-physics = blender53Pkgs.callPackage ./deps/jolt-physics/package.nix { };
        };
        nvidia-dlss-runtime = blender53Pkgs.callPackage ./deps/dlss/runtime.nix { };
        blender_5_3 = blender53Pkgs.callPackage ./blender/dlss-wrapper.nix {
          blender = blender53;
          inherit nvidia-dlss-runtime;
        };
        blender-with-cuda-stable = pkgs.blender.override {
          cudaSupport = true;
        };
        blender-with-cuda-unstable = unstablePkgsForSystem.blender.override {
          cudaSupport = true;
        };
        blender-with-cuda = blender-with-cuda-stable;
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
        };
        packages = {
          inherit blender-with-cuda blender-with-cuda-stable blender-with-cuda-unstable;
          inherit blender_5_3 nvidia-dlss-runtime;
          default = blender-with-cuda;
        };
      };

    };
}
