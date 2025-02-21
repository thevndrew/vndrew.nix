{pkgs, ...}: let
in
  pkgs.writeShellScriptBin "run_commands" ''
    #!/usr/bin/env bash
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <commands_file>"
        exit 1
    fi

    COMMANDS_FILE="$1"

    if [[ ! -f "$COMMANDS_FILE" ]]; then
        echo "Error: Command file '$COMMANDS_FILE' not found!"
        exit 1
    fi

    # Get the actual PS1 prompt
    # shellcheck disable=2034,2016
    REAL_PS1=$(bash --rcfile <(echo 'echo "$PS1"; exit') | tail -n 1)

    # Basic prompt
    # TERMINAL_PROMPT="$(whoami)@$(hostname):$(pwd)\n> " # Simulates a basic PS1 prompt

    BRACKET_COLOR="\033[38;5;35m"
    CLOCK_COLOR="\033[38;5;35m"
    JOB_COLOR="\033[38;5;33m"
    PATH_COLOR="\033[38;5;33m"
    LINE_BOTTOM="\u2500"
    LINE_BOTTOM_CORNER="\u2514"
    LINE_COLOR="\033[38;5;248m"
    LINE_STRAIGHT="\u2500"
    LINE_UPPER_CORNER="\u250C"
    END_CHARACTER=">"
    HOSTNAME_COLOR="\e[38;5;36m"
    USERNAME_COLOR="\e[38;5;32m"
    HISTORY_COLOR="\e[38;5;160m"
    TIME=$(date "+%T")

    TERMINAL_PROMPT="$LINE_COLOR$LINE_UPPER_CORNER$LINE_STRAIGHT$LINE_STRAIGHT$BRACKET_COLOR[$CLOCK_COLOR$TIME$BRACKET_COLOR]$LINE_COLOR$LINE_STRAIGHT$BRACKET_COLOR[$USERNAME_COLOR$(whoami)$BRACKET_COLOR@$(hostname):$PATH_COLOR$(pwd)$BRACKET_COLOR]\n$LINE_COLOR$LINE_BOTTOM_CORNER$LINE_STRAIGHT$LINE_BOTTOM$END_CHARACTER "

    update_prompt() {
        TIME=$(date "+%T")
        TERMINAL_PROMPT="$BRACKET_COLOR[$CLOCK_COLOR$TIME$BRACKET_COLOR]$LINE_COLOR$LINE_STRAIGHT$BRACKET_COLOR[$USERNAME_COLOR$(whoami)$BRACKET_COLOR@$(hostname):$PATH_COLOR$(pwd)$BRACKET_COLOR]\n$LINE_COLOR$LINE_BOTTOM_CORNER$LINE_STRAIGHT$LINE_BOTTOM$END_CHARACTER "
        echo -en "$TERMINAL_PROMPT"
    }

    type_command() {
        local cmd="$1"
        for ((i = 0; i < ''${#cmd}; i++)); do
            echo -n "''${cmd:$i:1}"
            sleep 0.02 # Adjust typing speed
        done
    }

    # Function to handle Ctrl+C
    handle_sigint() {
        if [[ -n "$CURRENT_PID" ]]; then
            echo -e "\nSkipping current command..."
            kill -SIGINT "$CURRENT_PID" 2>/dev/null  # Kill the running command
            wait "$CURRENT_PID" 2>/dev/null  # Wait for it to exit
        fi
    }

    pause() {
        # Wait for user input (Enter to continue, 'q' to quit)
        # shellcheck disable=2162
        read -s -n 1 -p "" key
        if [[ "$key" == "q" ]]; then
            echo -e "\nExiting..."
            exit 0
        fi
    }

    declare -a settings
    get_setting() {
        local -n arr="$1"
        flag="#''${arr[0]}"
        if [[ "$cmd" == *"$flag"* ]]; then
            cmd="''${cmd%%$flag*}"
            cmd=$(echo $cmd)
            arr[1]=1
        else
            arr[1]=0
        fi
        arr[0]="$cmd"
    }

    # Trap SIGINT (Ctrl+C) and call `handle_sigint`
    trap handle_sigint SIGINT

    clear

    #mapfile -t COMMANDS < <(grep -vE '^\s*#|^\s*$' "$COMMANDS_FILE")
    mapfile -t COMMANDS < <(grep -vE '^\s*$' "$COMMANDS_FILE")

    for cmd in "''${COMMANDS[@]}"; do
        settings[0]="clear"
        get_setting settings
        cmd=''${settings[0]}
        clear_screen=''${settings[1]}

        settings[0]="interactive"
        get_setting settings
        cmd=''${settings[0]}
        is_interactive=''${settings[1]}

        update_prompt

        pause

        type_command "$cmd"

        pause

        echo

        # Execute the command
        if [[ "$is_interactive" -eq "1" ]]; then
            eval "$cmd"
        else
            eval "$cmd" &
            CURRENT_PID=$!
            wait "$CURRENT_PID"
            CURRENT_PID=""
        fi

        if [[ "$clear_screen" -eq "1" ]]; then
            update_prompt
            pause
            clear
        fi
    done

    # Reset trap so script exits normally if Ctrl+C is pressed at the end
    trap - SIGINT

  ''
