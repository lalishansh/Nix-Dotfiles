{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  name = "hello-2.8";
  version = "2.12.1";
  src = pkgs.fetchurl {
    url = "mirror://gnu/hello/hello-${version}.tar.gz";
    sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
  };
}
