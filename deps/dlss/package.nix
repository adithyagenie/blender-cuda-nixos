{ fetchFromGitHub }:

# Keep the SDK version in sync with Blender's buildbot configuration.
fetchFromGitHub {
  name = "dlss-source";
  owner = "NVIDIA";
  repo = "DLSS";
  tag = "v310.9.1";
  sparseCheckout = [ "include" ];
  hash = "sha256-dGxcmb8iLQLlIkWCr8PESeajMsn69DQZ/erOGO5h8H0=";

  meta.license = {
    shortName = "NVIDIA RTX SDKs";
    fullName = "NVIDIA RTX SDKs";
    url = "https://developer.download.nvidia.com/gameworks/NVIDIA-RTX-SDKs-License-23Jan2023.pdf";
    free = false;
    redistributable = false;
  };
}
