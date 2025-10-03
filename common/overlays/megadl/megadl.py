#!/usr/bin/env python3
import argparse
import logging
import os
import random
import requests
from subprocess import Popen, PIPE, STDOUT
import sys

MULLVAD_API="https://api.mullvad.net/public/relays/wireguard/v2/"

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_directory(directory_path):
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)
        logger.info(f"Directory '{directory_path}' created.")
    else:
        logger.info(f"Directory '{directory_path}' already exists.")

def check_url(url):
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx and 5xx)
        logger.info(f"URL '{url}' is accessible.")
        return True
    except requests.exceptions.RequestException as e:
        logger.error(f"Error accessing URL '{url}': {e}")
        return False

def call_megatools(url, output_dir, proxy):
    try:
        create_directory(output_dir)

        # proxy = "socks5://es-mad-wg-socks5-201.relays.mullvad.net:1080"
        # proxy = "none"
        command = ["megatools", "dl", "--path", output_dir, "--proxy", proxy, url]
        sp = Popen(command, stdout=PIPE, stderr=STDOUT, bufsize=1, text=True)
        stall_count = 0

        logger.info(f'Starting Download with:\n{" ".join(command)}')

        for line in sp.stdout:
            if stall_count == 60:
                logger.error("Stalled out, restarting download")
                stall_count = 0
                sp.kill()
                return False
                #sp = Popen(command, stdout=PIPE, stderr=STDOUT, bufsize=1, text=True)
                #continue

            if "(0 bytes/s)" in line:
                stall_count += 1
            else:
                stall_count = 0

            errors = [
                "HTTP POST failed",
                "over quota",
                "Couldn't resolve host name",
                "Could not resolve proxy name",
                "Could not connect to server"
            ]

            if any(error.lower() in line.lower() for error in errors):
                logger.error(f"{line} (Hit an error trying another proxy)")
                return False
            logger.info(line.rstrip())
        return True
    except OSError as e:
        logger.error(f"Error calling 'megatools' for URL '{url}', with proxy '{proxy}': {e}")
        return False

def filter_downloads(lines):
    # Filter out blank lines and lines starting with #
    return [line.strip() for line in lines if line.strip() and not line.strip().startswith("#")]

def read_file(file_path):
    try:
        with open(file_path, 'r') as file:
            # Read lines from the file
            lines = file.readlines()
        return lines
    except FileNotFoundError:
        logger.error(f"File not found: {file_path}")
    except Exception as e:
        logger.error(f"Error reading file: {e}")

def create_tuples(filtered_lines):
    # Use list comprehension to create tuples from every two items
    return [(filtered_lines[i], filtered_lines[i + 1]) for i in range(0, len(filtered_lines), 2)]

def get_proxies_from_list(proxy_list):
    return [line.strip() for line in read_file(proxy_list)]

def modify_server_name(name):
    words = name.split('-')
    words.insert(-1, 'socks5')
    socks_name = '-'.join(words)
    return f"socks5://{socks_name}.relays.mullvad.net:1080"

def get_proxies():
    try:
        response = requests.get(MULLVAD_API)
        if response.status_code == 200:
            json_data = response.json()
            return [f"{modify_server_name(server['hostname'])}" for server in json_data["wireguard"]["relays"] if server['active'] == True]
        else:
            raise requests.HTTPError(f"Failed to fetch data. Status code: {response.status_code}")
    except Exception as e:
        raise e

def main():
    parser = argparse.ArgumentParser(description='Download files from mega with megatools')

    parser.add_argument('--directory', type=str, required=True, help='Path to the directory to be created')
    parser.add_argument('--links', required=True, help='Path to the file containing URLs.')
    #parser.add_argument('--proxies', required=True, help='Path to the file containing proxies.')
    args = parser.parse_args()

    filtered_lines = filter_downloads(read_file(args.links))
    #proxies = get_proxies(args.proxies)
    proxies = get_proxies()

    used = set()

    for subdir, link in create_tuples(filtered_lines):
        res = False
        while res == False:
            proxy = random.choice(proxies)
            if proxy in used:
                continue
            res = call_megatools(url=link, output_dir=f"{args.directory}/{subdir}", proxy=random.choice(proxies))
            if res == False:
                used.add(proxy)
            if len(used) == len(proxies):
                logger.info("All proxies used.")
                exit(1)

if __name__ == "__main__":
    main()
