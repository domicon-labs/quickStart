#!/usr/bin/env bash

# This script prints out the versions of the various tools used in the Getting
# Started quickstart guide on the docs site. Simplifies things for users so
# they can easily see if they're using the right versions of everything.

version() {
  local string=$1
  local version_regex='([0-9]+(\.[0-9]+)+)'
  if [[ $string =~ $version_regex ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo "No version found."
  fi
}

# Grab versions
ver_git=$(version "$(git --version)")
ver_go=$(version "$(go version)")
ver_pnpm=$(version "$(pnpm --version)")
ver_make=$(version "$(make --version)")


# Print versions
echo "Dependency | Minimum | Actual"
echo "git          2         $ver_git"
echo "go           1.21      $ver_go"
echo "pnpm         8         $ver_pnpm"
echo "make         3         $ver_make"

