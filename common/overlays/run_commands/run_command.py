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

# # Get the actual PS1 prompt
# REAL_PS1 = subprocess.run(
#     ["bash", "--rcfile", "/dev/stdin"],
#     input='echo "$PS1"; exit\n',
#     capture_output=True,
#     text=True,
#     shell=True,
# ).stdout.strip()

user = getpass.getuser()
host = socket.gethostname()
cwd = os.getcwd()
TERMINAL_PROMPT = f"{user}@{host}:{cwd}$ "  # Simulates a standard Linux prompt


def type_command(cmd):
    for char in cmd:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(0.05)


for cmd in commands:
    sys.stdout.write(TERMINAL_PROMPT)
    sys.stdout.flush()
    type_command(cmd)
    input()
    subprocess.run(
        cmd, shell=True, stdin=sys.stdin, stdout=sys.stdout, stderr=sys.stderr
    )
