#!/usr/bin/env python

import sys
import time
import subprocess
import socket, getpass, os

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <commands_file>")
    sys.exit(1)

COMMANDS_FILE = sys.argv[1]

try:
    with open(COMMANDS_FILE, "r") as file:
        commands = [
            line.strip() for line in file if line.strip() and not line.startswith("#")
        ]
except FileNotFoundError:
    print(f"Error: Command file '{COMMANDS_FILE}' not found!")
    sys.exit(1)

# ps1_raw = subprocess.run("zsh -i -c 'echo $PS1'", shell=True, capture_output=True, text=True).stdout.strip()
# PS1 = subprocess.run(f"zsh -i -c 'print -r -- {ps1_raw}'", shell=True, capture_output=True, text=True).stdout.strip()
# PS1 = PS1.replace("%{%}", "")

user = getpass.getuser()
host = socket.gethostname()
cwd = os.getcwd()
TERMINAL_PROMPT = f"{user}@{host}:{cwd}\n> "  # Simulates a standard Linux prompt


def type_command(cmd):
    for char in cmd:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(0.05)

subprocess.run("clear")

for cmd in commands:
    sys.stdout.write(TERMINAL_PROMPT)
    sys.stdout.flush()
    _ = input()
    sys.stdout.write("\033[1A\033[2K")
    sys.stdout.write("> ")
    sys.stdout.flush()
    type_command(cmd)
    _ = input()
    subprocess.run(
        cmd, shell=True, stdin=sys.stdin, stdout=sys.stdout, stderr=sys.stderr
    )
