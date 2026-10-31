#!/bin/sh
# Usage: sh bootstrap.sh [ansible-playbook options]
# Run as your developer account, not with sudo. Internet and sudo required.
set -eu

if [ "$(id -u)" -eq 0 ]; then
    echo 'Run as your normal developer account, without sudo.' >&2
    exit 1
fi

command -v apt-get >/dev/null
command -v sudo >/dev/null

bundle_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
install_dir="$HOME/.local/share/dev-bootstrap"

sudo -v
sudo apt-get update
sudo apt-get install -y ansible-core python3-apt rsync

mkdir -p "$install_dir"

rsync \
    -rt \
    --checksum \
    --exclude='.git/' \
    "$bundle_dir/" \
    "$install_dir/"

cd "$install_dir"

exec ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass "$@"
