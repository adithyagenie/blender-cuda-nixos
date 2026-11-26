{
  blender,
  callPackage,
  lib,
  makeWrapper,
  nvidia-dlss-runtime,
  runCommand,
}:

runCommand "${blender.pname}-${blender.version}-dlss" {
  inherit (blender) pname version meta;
  nativeBuildInputs = [ makeWrapper ];
  # Allow the launcher itself to be substituted for cache-only users.
  allowSubstitutes = true;
  preferLocalBuild = false;
  passthru = (blender.passthru or { }) // lib.optionalAttrs (blender ? withPackages) {
    withPackages = f: callPackage ./dlss-wrapper.nix {
      blender = blender.withPackages f;
      inherit nvidia-dlss-runtime;
    };
  };
} ''
  mkdir -p "$out/bin"
  shopt -s dotglob
  for entry in ${blender}/*; do
    if [[ "''${entry##*/}" != bin ]]; then
      ln -s "$entry" "$out/"
    fi
  done
  for entry in ${blender}/bin/*; do
    if [[ "''${entry##*/}" != blender ]]; then
      ln -s "$entry" "$out/bin/"
    fi
  done

  ngxDir="$out/.blender-ngx"
  mkdir "$ngxDir"
  ln -s /run/opengl-driver/lib/libnvidia-ngx.so.1 "$ngxDir/"
  ln -s ${nvidia-dlss-runtime}/lib/${nvidia-dlss-runtime.feature} "$ngxDir/libnvidia-ngx-builtin-dlssd.so"

  # NGX looks beside the path it used to load its core for the signed snippet.
  makeWrapper "${blender}/bin/blender" "$out/bin/blender" \
    --run '
      driverDir=/run/opengl-driver/lib
      if [[ -r "$driverDir/libnvidia-ngx.so.1" ]]; then
        export LD_LIBRARY_PATH="'"$ngxDir"':$driverDir''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      fi'
''
