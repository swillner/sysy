#!/usr/bin/env bash
set -e

if ! which realpath >/dev/null 2>/dev/null
then
    echo "Could not find realpath executable" 1>&2
    sudo apt-get install coreutils
fi

if ! which diff >/dev/null 2>/dev/null
then
    echo "Could not find diff executable" 1>&2
    sudo apt-get install diffutils
fi

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
    open_in_editor "$confdir/tags"
fi

echo "Bootstrapping and syncing packages..."
bash "$dosydir/bin/pasy" bootstrap
bash "$dosydir/bin/pasy" sync
echo "Syncing system configuration..."
bash "$dosydir/bin/cosy" sync
echo "Syncing dotfiles..."
bash "$dosydir/bin/dosy" sync
