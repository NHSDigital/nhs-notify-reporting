#!/usr/bin/env bash

# WARNING: Please DO NOT edit this file! It is maintained in the Repository Template (https://github.com/NHSDigital/nhs-notify-repository-template). Raise a PR instead.

set -euo pipefail

# Terraform-docs command wrapper. It will run the command natively if terraform-docs is
# installed, otherwise it will run it in a Docker container.
# Run terraform-docs for generating Terraform module documentation code.
#
# Usage:
#   $ ./terraform-docs.sh [directory]
# ==============================================================================

function main() {

  cd "$(git rev-parse --show-toplevel)"

  local dir_to_document=${1:-.}

  if command -v terraform-docs > /dev/null 2>&1 && ! is-arg-true "${FORCE_USE_DOCKER:-false}"; then
    # shellcheck disable=SC2154
    run-terraform-docs-natively "$dir_to_document"
  else
    run-terraform-docs-in-docker "$dir_to_document"
  fi
}

# Run terraform-docs on the specified directory.
# Arguments:
#   $1 - Directory to document
function run-terraform-docs-natively() {

  local dir_to_scan="$1"
  echo "Terraform-docs found locally, running natively"
  if [ -d "$dir_to_scan" ]; then
    echo "Running Terraform-docs on directory: $dir_to_scan"
    terraform-docs \
      -c scripts/config/terraform-docs.yml \
      --output-file README.md \
      "$dir_to_scan"
  fi
}

function run-terraform-docs-in-docker() {

  # shellcheck disable=SC1091
  source ./scripts/docker/docker.lib.sh
  local dir_to_scan="$1"

  # shellcheck disable=SC2155
  local image=$(name=quay.io/terraform-docs/terraform-docs docker-get-image-version-and-pull)
  # shellcheck disable=SC2086
  echo "Terraform-docs not found locally, running in Docker Container"
  echo "Running Terraform-docs on directory: $dir_to_scan"
  docker run --rm --platform linux/amd64 \
    --volume "$PWD":/workdir \
    --workdir /workdir \
    "$image" \
      -c scripts/config/terraform-docs.yml \
      --output-file README.md \
      "$dir_to_scan"

}
# ==============================================================================

function is-arg-true() {

  if [[ "$1" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$ ]]; then
    return 0
  else
    return 1
  fi
}

# ==============================================================================

is-arg-true "${VERBOSE:-false}" && set -x

main "$@"

exit 0
