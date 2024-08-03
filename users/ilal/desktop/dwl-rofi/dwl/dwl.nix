{
pkgs,
lib,
conf ? null,
termcmd ? null,
menucmd ? null,
volupcmd ? null, voldowncmd ? null, volmutecmd ? null,
brupcmd ? null, brdowncmd ? null,
enableXWayland ? true,
...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "dwl";
  version = "0.5";

  src = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "dwl";
    repo = "dwl";
    rev = "v${version}";
    hash = "sha256-U/vqGE1dJKgEGTfPMw02z5KJbZLWY1vwDJWnJxT8urM=";
  };

  nativeBuildInputs = with pkgs; [
    installShellFiles
    pkg-config
    wayland-scanner
  ];

  buildInputs = with pkgs; [
    libinput
    xorg.libxcb
    libxkbcommon
    pixman
    wayland
    wayland-protocols
    wlroots
    xdg-desktop-portal
		xdg-desktop-portal-wlr
		xdg-desktop-portal-gtk
  ] ++ lib.optionals enableXWayland [
    xorg.libX11
    xorg.xcbutilwm
    xwayland
  ];

  outputs = [ "out" "man" ];

  # Allow users to set an alternative config.def.h
  postPatch = let configFile =
      if conf != null
        then if lib.isDerivation conf || builtins.isPath conf
            then conf
            else lib.writeText "config.def.h" conf
        else pkgs.substituteAll {
          src = ./config.h;
          termcmd = "${termcmd}";
          menucmd = "${menucmd}";
          volupcmd = "${volupcmd}";
          voldowncmd = "${voldowncmd}";
          volmutecmd = "${volmutecmd}";
          brupcmd = "${brupcmd}";
          brdowncmd = "${brdowncmd}";
        };
      in "cp ${configFile} config.def.h";

  makeFlags = [
    "PKG_CONFIG=${pkgs.stdenv.cc.targetPrefix}pkg-config"
    "WAYLAND_SCANNER=wayland-scanner"
    "PREFIX=$(out)"
    "MANDIR=$(man)/share/man"
  ];

  preBuild = ''
    makeFlagsArray+=(
      XWAYLAND=${lib.optionalString enableXWayland "-DXWAYLAND"}
      XLIBS=${lib.optionalString enableXWayland "xcb\\ xcb-icccm"}
      CFLAGS="-Wno-unused-function"
    )
  '';
}
