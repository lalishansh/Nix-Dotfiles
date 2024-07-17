#!/usr/bin/env bash

set -e

pushd "$(dirname "$0")" > /dev/null

logfile="/tmp/nixos-rebuild.log"
touch "$logfile"

raise_error() {
    cat $logfile
    git diff HEAD --minimal --ignore-space-change --ignore-submodules --ignore-all-space
    popd > /dev/null
    exit 1
}

# 1. Add changes to git
git add .

# 2. Run nixos-rebuild switch
sudo nixos-rebuild switch --show-trace || raise_error

# 3. Commit changes and exit
git commit -am "$(nixos-rebuild list-generations | grep current)"

popd > /dev/null
echo "NixOS Rebuild successful"
exit 0
