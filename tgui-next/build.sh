#!/bin/bash
## Script for building tgui. Requires MSYS2 to run.
set -e
cd "$(dirname "${0}")"
base_dir="$(pwd)"

## Add locally installed node programs to path
PATH="${PATH}:node_modules/.bin"

yarn install

run-webpack() {
  cd "${base_dir}/packages/tgui"
  exec webpack "${@}"
}

## Run a development server
if [[ ${1} == "--dev" ]]; then
  shift
  cd "${base_dir}/packages/tgui-dev-server"
  exec node --experimental-modules index.js "${@}"
fi

## Run a linter through all packages
if [[ ${1} == '--lint' ]]; then
  shift
  exec eslint ./packages "${@}"
fi

## Analyze the bundle
if [[ ${1} == '--analyze' ]]; then
  run-webpack --mode=production --analyze
fi

## Make a production webpack build
if [[ -z ${1} ]]; then
  run-webpack --mode=production
fi

## Run webpack with custom flags
run-webpack "${@}"
