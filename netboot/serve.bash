#!/usr/bin/env bash

set -eu -o pipefail

dir=$(mktemp -t -d netboot.XXXXXXXXXXXXX)
trap 'rm -rf "$dir"' EXIT

nix-build --out-link "$dir/result" "${0%%/*}"

n="$(realpath "$dir/result")"
init=$(grep -ohP 'init=\S+' "$n"/netboot.ipxe)

nix build -o "$dir/pixiecore" nixpkgs#pixiecore

sudo iptables -I INPUT -p tcp -m tcp --dport 64172 -j ACCEPT
sudo iptables -I INPUT -p udp -m udp --dport 69 -j ACCEPT

sudo "$dir/pixiecore/bin/pixiecore" \
     boot "$n/bzImage" "$n/initrd" \
     --cmdline "$init loglevel=4" \
     --debug --log-timestamps --dhcp-no-bind --port 64172 --status-port 64172
