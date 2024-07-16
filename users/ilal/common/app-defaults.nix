{ pkgs, lib, ... }:

with lib;
let
  browsers = [
    "floorp.desktop"
    "floorp-work.desktop"
    "firefox.desktop"
    "tor-browser.desktop"
  ];

  defaultApps = {
    # used /etc/profiles/per-user/ilal/share/applications/ as reference
    text = [ "dev.zed.Zed.desktop" ];
    image = [ "feh.desktop" ];
    audio = [ "mpv.desktop" ];
    video = [ "mpv.desktop" ];
    directory = [ "lf.desktop" ];
    mail = [ "re.sonny.Junction.desktop" ] ++ browsers;
    calendar = [ "re.sonny.Junction.desktop" ] ++ browsers;
    browser = [ "re.sonny.Junction.desktop" ] ++ browsers;
    office = [ "libreoffice.desktop" ];
    pdf = [ "re.sonny.Junction.desktop" ] ++ browsers;
    ebook = [ "re.sonny.Junction.desktop" ] ++ browsers; # TODO: calibre
    magnet = [ "com.github.persepolisdm.persepolis.desktop" ];
  };

  mimeMap = {
    text = [ "text/plain" ];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/x-matroska"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
    ];
    directory = [ "inode/directory" ];
    mail = [ "x-scheme-handler/mailto" ];
    calendar = [
      "text/calendar"
      "x-scheme-handler/webcal"
    ];
    browser = [
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
    ];
    office = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/rtf"
    ];
    pdf = [ "application/pdf" ];
    ebook = [ "application/epub+zip" ];
    magnet = [ "x-scheme-handler/magnet" ];
  };

  associations =
    with lists;
    listToAttrs (
      flatten (mapAttrsToList (key: map (type: attrsets.nameValuePair type defaultApps."${key}")) mimeMap)
    );

  noCalibre =
    let
      mimeTypes = [
        "application/vnd.oasis.opendocument.text"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "text/html"
        "text/x-markdown"
      ];
      desktopFiles = [
        "calibre-ebook-edit.desktop"
        "calibre-ebook-viewer.desktop"
        "calibre-gui.desktop"
      ];
    in
    lib.zipAttrs (map (d: lib.genAttrs mimeTypes (_: d)) desktopFiles);
in
{
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.associations.removed = noCalibre;
  xdg.mimeApps.defaultApplications = associations;

  home.packages = with pkgs; [
    #floorp-unwrapped # 11.14.1 is broken
    tor-browser

    zed-editor
    typst
    nixd
    nixpkgs-fmt
    vale-ls

    feh
    yt-dlp
    lf

    junction

    aria2
    persepolis
  ];

  systemd.user.services.aria2 = {
    Unit = {
      Description = "aria2 service";
      After = [ "network.target" "network.service" ];
    };
    Service = {
      Restart = "on-abort";
      ExecStart = "
      cfgFile='~/.config/aria2/aria2.conf'
      ssnFile='~/Downloads/.aria2/aria2.session'
      mkdir -p $(dirname $sessionfile) && touch $sessionfile
      ${lib.getExe pkgs.aria2} --conf-path=$configfile --save-session=$sessionfile
      ";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Copy app specific configs, for symlinks use `config.lib.file.mkOutOfStoreSymlink + <absolute-path>` instead of <path>
  home.file = {
    ".config/foot/foot.ini".source = ./foot-terminal.ini;
    ".config/zed" = { source = ./zed; recursive = true; };
    ".config/aria2/aria2.conf".source = ./aria2.conf;
  };

  programs.firefox = {
    enable = true;
    profiles.basic = {
      isDefault = true;
      settings = {
        "gfx.webrender.overlay-vp-auto-hdr" = true;
        "gfx.webrender.overlay-vp-super-resolution" = true;
        "mousewheel.with_control.action" = 5;
        "mousewheel.with_control.delta_multiplier_x" = 200;
        "mousewheel.with_control.delta_multiplier_y" = 200;
        "mousewheel.with_control.delta_multiplier_z" = 200;
      };
      bookmarks = [
        { name = "Nix Option(s) (Unstable)"; tags = [ "nix" ]; keyword = "nixop"; url = "https://search.nixos.org/options?channel=unstable&query=%s"; }
      ];
    };
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs; [
      mpvScripts.uosc
      mpvScripts.thumbfast
      mpvScripts.autoload
      mpvScripts.autocrop
    ];
    config = {
      osd-bar = "no"; # uosc provides seeking & volume indicators
      border = "no"; # uosc will draw window controls and border
      slang = "en";
      save-position-on-quit = "yes";

      vo = "gpu-next";
      hwdec = "auto";
      gpu-context = "wayland";
      gpu-api = "vulkan";

      audio-channels = "auto";
    };
    bindings = {
      "Ctrl+o" = "script-binding uosc/open-file";
    };
    defaultProfiles = [ "gpu-hq" ];
  };

  home.sessionVariables = {
    # prevent wine from creating file associations
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };
}
