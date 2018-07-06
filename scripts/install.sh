#!/usr/bin/env bash
scriptpath=$(dirname "$(realpath "$0")")
confdir=$HOME/.dosy.d
dosydir=$(dirname "$scriptpath")

# shellcheck source=/home/sven/sync/dosy/scripts/include.sh
source "$scriptpath/../scripts/include.sh"

mkdir -p "$confdir"
ln -is "$dosydir/bin" "$confdir"
touch "$confdir/tags"
if ask_user "Edit tags now?" "y"
then
    $VISUAL "$confdir/tags"
fi
