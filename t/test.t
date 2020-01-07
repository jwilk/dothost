#!/bin/sh

# Copyright © 2019 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
echo 1..6
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
tmpdir=$(mktemp -d -t dothost.XXXXXX)
RES_OPTIONS=attempts:0 "$prog" localhost > "$tmpdir/test.dot"
echo "ok 1"
sed -e 's/^/# /' "$tmpdir/test.dot"
if command -v dot > /dev/null
then
    dot < "$tmpdir/test.dot" > /dev/null
    echo "ok 2"
else
    echo "ok 2 # skip dot(1) not found"
fi
if command -v graph-easy > /dev/null
then
    graph-easy --as boxart < "$tmpdir/test.dot" > "$tmpdir/test.txt"
    sed -e 's/^/# /' "$tmpdir/test.txt"
    echo "ok 3"
else
    echo "ok 3 # skip graph-easy(1) not found"
fi
if [ -n "${DOTHOST_TEST_NETWORK:-}" ]
then
    "$prog" www.iana.org > "$tmpdir/test.dot"
    echo "ok 4"
    sed -e 's/^/# /' "$tmpdir/test.dot"
    if command -v dot > /dev/null
    then
        dot < "$tmpdir/test.dot" > /dev/null
        echo "ok 5"
    else
        echo "ok 5 # skip dot(1) not found"
    fi
    if command -v graph-easy > /dev/null
    then
        graph-easy --as boxart < "$tmpdir/test.dot" > "$tmpdir/test.txt"
        sed -e 's/^/# /' "$tmpdir/test.txt"
        echo "ok 6"
    else
        echo "ok 6 # skip graph-easy(1) not found"
    fi
else
    printf 'ok %d # skip DOTHOST_TEST_NETWORK not set\n' 4 5 6
fi
rm -rf "$tmpdir"

# vim:ts=4 sts=4 sw=4 et ft=sh
