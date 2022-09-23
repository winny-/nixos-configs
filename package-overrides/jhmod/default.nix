{ lib, buildGoModule, fetchFromGitHub }:
with lib;
buildGoModule {
  name = "jhmod";

  src = fetchFromGitHub {
    owner = "sector-f";
    repo = "jhmod";
    rev = "858415bbc9519e67ed5c8a420c310f0ecb51e97c";
    # Substitute with fakeHash to get the hash if you don't know it.
    sha256 = "sha256-1PfFta5qLz56/xBZEG+WxgmLHlphRBXnRmFhwm2QtlI=";
  };

  vendorSha256 = "sha256-xBUeWmMBZLz2LRihi6NtNT9mLIST7/vFwBVp2ZZZyy4=";

}
