{
  pkgs,
  sshProvider ? "openssh",
  host ? "github.com",
  identityFile ? "~/.ssh/github",
  email ? null,
  name ? null,
  ...
}:{
  programs.ssh = {
    enable = true;
    package = pkgs.${sshProvider};
    extraConfig = "
        Host ${host}
        User git
        IdentityFile ${identityFile}
        PreferredAuthentications publickey
    ";
  };
  programs.git = {
    userName = name;
    userEmail = email;
    lfs.enable = true;
  };
}
