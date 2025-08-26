#!/usr/bin/env bash
config_yaml=$1
stream=$2

url=$(yq -r ".streams.$stream.url" "$config_yaml")
args=$(yq -r ".streams.$stream.args // \"\"" "$config_yaml")

if [[ -z $(echo "$args" | tr -d '"') ]]; then
   args=""
   for name in youtube twitch; do
      if [[ $url == *"$name"* ]]; then
	   args=$(yq -r ".$name.default_args" "$config_yaml")
      fi
   done
fi


set +o errexit

while true;
do
    # shellcheck disable=SC2086
    eval "$args '$url'";
    sleep 60;
done
