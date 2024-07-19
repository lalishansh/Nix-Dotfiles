#!/usr/bin/env bash

set -e

pushd "$(dirname "$0")" > /dev/null

raise_error() {
    git diff HEAD --minimal --ignore-space-change --ignore-submodules --ignore-all-space
    popd > /dev/null
    exit 1
}

# 1. Add changes to git
git add .

# 2. Run nixos-rebuild switch
(sudo nixos-rebuild switch --show-trace 2>&1) || raise_error # log to file and stdout

# 3. Commit changes and exit
git commit -am "$(nixos-rebuild list-generations | grep current)"

popd > /dev/null
echo "NixOS Rebuild successful"
exit 0
