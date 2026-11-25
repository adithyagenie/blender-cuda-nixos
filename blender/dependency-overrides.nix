final: prev:
{
  opentimelineio = prev.opentimelineio.overrideAttrs (old: {
    src = old.src.override {
      rev = "31e3101e750be2aa992274ac02c0679077872e57"; # Blender's pinned revision
      hash = "sha256-Rpx/PMqhmW1MNTaOLaALB/o47GNrCaWG0JbEeN2vHn8=";
    };

    patches = (old.patches or [ ]) ++ [
      (final.fetchpatch2 {
        url = "https://github.com/AcademySoftwareFoundation/OpenTimelineIO/commit/8ab0cf963624cfe3daf3c79c937cf603b4ef783b.patch?full_index=1";
        hash = "sha256-EpE2c2ME36ryNMtQgiWwj8uis0Qwizm6mvmN72D0DdU=";
      })
    ];

    buildInputs = old.buildInputs ++ [
      final.minizip-ng
      final.zlib
    ];
    cmakeFlags = old.cmakeFlags ++ [
      "-DOTIO_FIND_MINIZIP_NG=1"
      "-DOTIO_FIND_RAPIDJSON=1"
    ];
  });
}
