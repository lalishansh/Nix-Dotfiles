{ pkgs, pkgs-stable, ... }:
let
in
{
  packages = with pkgs; [
    floorp-bin
    fzf # command-line fuzzy finder, awesome tool, master it

    youtube-music
    qbittorrent
    (mpv.override {
      scripts = with pkgs.mpvScripts;
        [ uosc autoload thumbfast autocrop ]
        ++ lib.optional pkgs.stdenv.isLinux pkgs.mpvScripts.mpris;
    })
    anime4k
    htop

    (anki.withAddons [
      ankiAddons.anki-connect
      ankiAddons.review-heatmap
    ])

    kdePackages.kdeconnect-kde
    kitty

    (yazi.override {
      extraPackages = with pkgs; [
        mediainfo
        util-linux
        udisks
        wl-clipboard
      ];
      plugins = {
        inherit (pkgs.yaziPlugins) bypass chmod mount mediainfo wl-clipboard; #git
      };
      settings.keymap = {
        input.prepend.keymap = [
          { on = "<Esc>"; run = "close --submit"; desc = "Cancel input"; } # How does it work?
        ];
        mgr.prepend_keymap = [
          { on = "l"; run = "plugin bypass smart-enter"; desc = "Open a file, or recursively enter child directory, skipping children with only a single subdirectory"; }
          { on = "h"; run = "plugin bypass reverse"; desc = "Recursively enter parent directory, skipping parents with only a single subdirectory"; }
          { on = [ "c" "m" ]; run  = "plugin chmod"; desc = "Chmod on selected files"; }
          { on = "M"; run = "plugin mount"; desc = "Mount manager"; }
          { on = "<C-y>"; run = [ "plugin wl-clipboard" "yank" ]; desc = "Copy to system clipboard"; }
        ];
      };
      settings.yazi = {
        mgr.show_hidden = true;
        tasks.image_alloc = 1024 * 1024 * 1024;
        plugin.prepend_preloaders = [
          { mime = "{audio,video,image}/*"; run = "mediainfo"; }
          { mime = "application/subrip"; run = "mediainfo"; }
          { mime = "application/postscript"; run = "mediainfo"; }
        ];
        plugin.prepend_previewers = [
          { mime = "{audio,video,image}/*"; run = "mediainfo"; }
          { mime = "application/subrip"; run = "mediainfo"; }
          { mime = "application/postscript"; run = "mediainfo"; }
        ];
      };
    })

    gimp

    zed-editor
    git
    nixd  # Nix Language Server
    hugo  # Website
    # Resume
    typst tinymist
    # C++
    cmake ninja
    llvmPackages.clang
    gcc gdb
    binutils
    # Rust
    cargo rustc
  ] ++ [
    # Flatpak and related packages
    # Note: use 'flatpak override --user com.jetbrains.RustRover --talk-name=org.freedesktop.Flatpak' for flatpak-spawn access
    # then you can do things like '/usr/bin/flatpak-spawn --host --env=TERM=xterm-256color bash -c bash' from inside flatpak app
    flatpak
    fuse3
    cosmic-store
  ];

  home_dir.".profile".text = ''
   # Flatpak support
   export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
  '';

  home_dir.".bashrc".text = ''
    export HISTCONTROL=ignoreboth:erasedups
    export EDITOR=zed
    export VISUAL=zed

    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_COMPLETION_TRIGGER='``'
    # ignore '.git', 'node_modules', '!build' folders
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude !build'
    if command -v fzf-share >/dev/null; then
      # CTRL-T - Paste the selected file path into the command line
      # CTRL-R - Paste the selected command from history into the command line
      # ALT-C - Paste the selected directory path into the command line and cd to it
      source "$(fzf-share)/key-bindings.bash"
      source "$(fzf-share)/completion.bash"
    fi

    z() { (( $# != 0 )) && pushd "$1" || popd; }
    alias l='ls -ACF --color=auto'
    alias gs='git status'
    alias gd='git diff'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git pull'
    alias gb='git branch'
    alias gco='git checkout'
    alias gcb='git checkout -b'
    alias v='zed .'
    alias c='clear'
    alias cls='clear'
    alias h='history'
    alias j='jobs -l'
    alias ..='z ..'
    alias ...='z ../..'
    alias ....='z ../../..'
    alias .....='z ../../../..'
    alias ......='z ../../../../..'
    alias ~='z ~'
    alias reload='source ~/.bashrc && echo "Reloaded!"'
  '';

  # curl -sL https://github.com/bloc97/Anime4K/raw/master/md/Template/GLSL_Mac_Linux_Low-end/input.conf | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e "s| | |" -e "s|$||"
  config_dir."mpv/input.conf".text = with pkgs; ''
    Ctrl+o script-binding uosc/open-file
    CTRL+1 no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"
    CTRL+2 no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"
    CTRL+3 no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"
    CTRL+4 no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"
    CTRL+5 no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"
    CTRL+6 no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"
    CTRL+0 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
  '';
  config_dir."mpv/mpv.conf".text = ''
    # uosc provides seeking & volume indicators
    osd-bar=no
    # uosc will draw window controls and border
    border=no

    slang=en
    save-position-on-quit
    watch-later-options=start,speed,vid,aid,sid,secondary-sid,audio-delay,sub-delay,secondary-sub-delay,mute,sub-visibility,secondary-sub-visibility,fullscreen
    force-window=yes
    idle=once

    vo=gpu
    hwdec=auto
    audio-channels=auto

    profile=gpu-hq

    # Script options
    # Autocrop
    script-opts-append=autocrop-detect_seconds=4
  '';

  config_dir."kitty/kitty.conf".source = ./kitty.conf;
}
