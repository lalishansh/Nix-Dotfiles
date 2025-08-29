sudo nixos-rebuild switch --flake .#NixOS-Laptop --impure

# Need help
we need to write a nix options for adding an option under `users.users.<name>` like `path."path/to/file/or/folder/from/home".copy = "./local/path/to/file/or/folder"`
this copies file or folder from ./local/path/to/file/or/folder to ~/path/to/file/or/folder/from/home

example:
```# users/alice/default.nix
imports = [
  ../shared/options.nix
];
users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = [ pkgs.firefox, pkgs.kitty, pkgs.zed-editor ];
    path = {
        ".config/kitty/kitty.conf".copy = "./kitty.conf"; # file
        ".config/zed".copy = "./zed"; # folder
    };
};
```
```# users/shared/options.nix
# PUT OPTION `users.users.<name>.path` HERE
```

create a type `theBasePathOpts` for `users.users.<name>.path`

```users/alice/desktop-env.nix
{
  packages = with pkgs; [
    kitty
    hyprland
  ]
  # Blah blah blah
}
```
```users/alice/development.nix
{
  packages = with pkgs; [
    zeditor
    neovim
  ]
  # Blah blah blah 2
}
```
```users/alice/default.nix
{
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = [ pkgs.firefox pkgs.kitty pkgs.zed-editor ];

    # somthing like this
    (import users/alice/desktop-env.nix)
    (import users/alice/development.nix)
  }
}
```
