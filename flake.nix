{
  description = "Blender with CUDA";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
          default = blender-with-cuda;
        };
      };

    };
}
