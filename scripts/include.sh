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
            if [ "$2" != "y" ] && [ "$response" = "" ]
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
