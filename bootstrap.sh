#!/bin/bash

set -e

function abort_if_missing_dependencies {
  # --print-path exits 0 if installed, 2 otherwise
  if ! xcode-select --print-path > /dev/null; then
    echo 'The XCode CLI tools are required. Please run `xcode-select --install` first.'
    exit 2
  fi
}

abort_if_missing_dependencies
make
