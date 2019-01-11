#!/usr/bin/env bash

# shellcheck disable=SC2034
COLOR_BLACK='\033[0;30m'
COLOR_DARK_GRAY='\033[1;30m'
COLOR_RED='\033[0;31m'
COLOR_LIGHT_RED='\033[1;31m'
COLOR_GREEN='\033[0;32m'
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_ORANGE='\033[0;33m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_LIGHT_PURPLE='\033[1;35m'
COLOR_CYAN='\033[0;36m'
COLOR_LIGHT_CYAN='\033[1;36m'
COLOR_LIGHT_GRAY='\033[0;37m'
COLOR_WHITE='\033[1;37m'
COLOR_CLEAR='\033[0m'

info () {
    echo -e "$COLOR_LIGHT_BLUE$1$COLOR_CLEAR"
}

error () {
    echo -e "$COLOR_RED$1$COLOR_CLEAR" 1>&2
}

error_and_exit () {
    error "$1"
    exit "${2:-1}"
}

print_global_options () {
    cat <<EOF

Options:

    Use environment variable ALWAYS_ANSWER to always select "y" or "n"
    in questions.
EOF
}

ask_user () {
    local question=$1
    local default=$2
    local default_indicator
    if [[ "$default" = "y" ]]
    then
        default_indicator="[Y/n]"
    else
        default_indicator="[y/N]"
    fi
    local response
    echo -e -n "$COLOR_ORANGE$question$COLOR_CLEAR $COLOR_LIGHT_GRAY$default_indicator$COLOR_CLEAR "
    if [[ -z "$ALWAYS_ANSWER" ]]
    then
        read -r response < /dev/tty
    else
        response=$ALWAYS_ANSWER
    fi
    case $response in
        [yY][eE][sS]|[yY]|'')
            if [[ "$default" != "y" && "$response" == "" ]]
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

ask_run () {
    cmd=$1
    desc=$2
    [[ -z "$desc" ]] || desc=" ($desc)"
    echo -e "${COLOR_ORANGE}Would run$desc\\n$COLOR_YELLOW  $cmd$COLOR_RESET"
    if ask_user "Run?" "y"
    then
        eval "$cmd"
    fi
}

ensure_link () {
    local from=$1
    local to=$2
    if [[ ! -e "$to" ]]
    then
        ln -sf "$from" "$to"
    else
        real=$(realpath "$to")
        if [[ "$real" != "$from" ]]
        then
            if [[ "$real" == "$to" ]]
            then
                if ask_user "Replace $to by link to $from?" "y"
                then
                    ln -sf "$from" "$to"
                fi
            else
                if ask_user "Replace $to by link to $from (currently to $real)?" "y"
                then
                    rm "$to"
                    ln -s "$from" "$to"
                fi
            fi
        fi
    fi
}

ask_to_install_if_not_found () {
    local command=$1
    if command -v "$command" >/dev/null 2>/dev/null
    then
        return 1
    else
        error "Could not find $command executable"
        if ask_user "Install $command now?" "y"
        then
            info "Installing $command..."
            return 0
        else
            error_and_exit "Aborting" 2
        fi
    fi
}

open_in_editor () {
    if [[ -n "$VISUAL" ]]
    then
        $VISUAL "$@"
    else
        if [[ -n "$EDITOR" ]]
        then
            $EDITOR "$@"
        else
            nano "$@"
        fi
    fi
}
