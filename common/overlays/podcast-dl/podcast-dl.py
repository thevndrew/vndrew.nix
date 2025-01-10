#!/usr/bin/env python3
import argparse
import logging
import os
import subprocess
import sys
import time
from typing import Dict, List, Set, Union

import yaml

logging.basicConfig(
    format="%(funcName)s - %(asctime)s - %(message)s",
    level=logging.INFO,
    datefmt="%d-%b-%y %H:%M:%S",
)


def main():

    logger = logging.getLogger(__name__)

    parser = argparse.ArgumentParser(
        prog="podcast-dl",
        usage="%(prog)s [options]",
        description="Download podcasts with yt-dlp",
    )

    parser.add_argument(
        "--verbose", "-v", action="store_true", help="enable verbose logging"
    )

    parser.add_argument(
        "--config", required=True, help="config with list of pods to dl"
    )

    parser.add_argument(
        "--output", "-o", default=os.getcwd(), help="directory to output podcasts"
    )

    args = parser.parse_args()

    logger.setLevel(logging.DEBUG if args.verbose else logging.INFO)

    if not os.path.isfile(args.config):
        logger.error(f"{args.config} is does not exists!!!")
        exit(1)

    with open(args.config, "r") as f:
        config = yaml.safe_load(f)
        yt_dl_args = [str(a) for a in config.get("args", [])]
        podcasts = config.get("podcasts", [])

    for pod in podcasts:
        pod_args = (
            yt_dl_args
            + pod.get("args", [])
            + [
                "--download-archive",
                "{0}/{1}-archive.txt".format(
                    args.output, pod["name"].replace(" ", "_")
                ),
                "--output",
                "{0}/{1}".format(args.output, pod["template"]),
                "{0}".format(pod["url"]),
            ]
        )

        logger.debug("Running yt-dlp with args: {0}".format(" ".join(pod_args)))

        subprocess.run(["yt-dlp"] + pod_args)


if __name__ == "__main__":
    main()
