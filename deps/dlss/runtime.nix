{
  fetchurl,
  lib,
  runCommand,
}:

let
  version = "310.9.1";
  sdk = "https://raw.githubusercontent.com/NVIDIA/DLSS/v${version}";
  feature = "libnvidia-ngx-dlssd.so.${version}";
  library = fetchurl {
    url = "${sdk}/lib/Linux_x86_64/rel/${feature}";
    hash = "sha256-FQQ7QSmkILCdzUWgKUyxXxNdojBUYCgn9oCV+AgLBbA=";
  };
  license = fetchurl {
    url = "${sdk}/LICENSE.txt";
    name = "nvidia-dlss-sdk-${version}-LICENSE.txt";
    hash = "sha256-1CFuOevvX5tQpnEuuze+61N5hipnczqZmcZR8hWSqvA=";
  };
in
runCommand "nvidia-dlss-runtime-${version}" {
  inherit version;
  passthru = { inherit feature; };
  # NGX verifies NVIDIA's signature on the original ELF bytes.
  dontFixup = true;
  meta = {
    description = "Signed NVIDIA DLSS Ray Reconstruction runtime from the RTX SDK";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
} ''
  install -Dm644 ${library} "$out/lib/${feature}"
  install -Dm644 ${license} "$out/share/licenses/nvidia-dlss-runtime/LICENSE"
''
