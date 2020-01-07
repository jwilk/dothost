#!/bin/sh

# Copyright © 2019 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
echo 1..3
base="${0%/*}/.."
prog="${DOTHOST_TEST_TARGET:-"$base/dothost"}"
if [ "${prog%/*}" = "$prog" ]
then
    orig_prog="$prog"
    prog=$(command -v "$prog") || {
        printf '%s: command not found\n' "$orig_prog" >&2
        exit 1
    }
fi
echo "# test target = $prog"
IFS='(); ' read -r _ changelog_version changelog_dist _ < "$base/doc/changelog"
echo "# changelog version = $changelog_version"
echo "# changelog dist = $changelog_dist"
line=$(grep '^__version__ *=' "$prog")
IFS=" ='" read -r _ _ cli_version <<EOF
$line
EOF
echo "# CLI version = $cli_version"
[ "$cli_version" = "$changelog_version" ]
echo "ok 1 CLI version == changelog version"
if [ -d "$base/.git" ]
then
    echo 'ok 2 # skip git checkout'
else
    [ "$changelog_dist" != UNRELEASED ]
    echo 'ok 2 distribution != UNRELEASED'
fi
line=$(grep '^[.]TH ' "$base/doc/"*.1)
IFS=' "' read -r _ _ _ _ _ man_version _ <<EOF
$line
EOF
echo "# man page version = $man_version"
[ "$cli_version" = "$man_version" ]
echo "ok 3 CLI version == man page version"

# vim:ts=4 sts=4 sw=4 et ft=sh
