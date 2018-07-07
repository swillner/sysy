#!/usr/bin/env bash

ask_user () {
    local default_indicator
    if [ "$2" = "y" ]
    then
        default_indicator="[Y/n]"
    else
        default_indicator="[y/N]"
    fi
    local response
    read -r -p "$1 $default_indicator " response
    case $response in
        [yY][eE][sS]|[yY]|'')
            if [ "$2" != "y" ] && [ "$response" == "" ]
            then
                return 1
            else
                return 0
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

ensure_command () {
    local command=$1
    local package=${2:-$command}
    if ! which "$command" >/dev/null 2>/dev/null
    then
        echo "Could not find $command executable" 1>&2
        if ask_user "Install $package package now?" "y"
        then
            sudo apt-get install "$package"
        else
            echo "Aborting" 1>&2
            exit 2
        fi
    fi
}

open_in_editor () {
    if [ ! -z "$VISUAL" ]
    then
        $VISUAL "$@"
    else
        if [ ! -z "$EDITOR" ]
        then
            $EDITOR "$@"
        else
            emacs "$@"
        fi
    fi
}
