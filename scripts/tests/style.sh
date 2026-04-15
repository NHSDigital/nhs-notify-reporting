#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"


# This file is for you! Edit it to call your prose style checker.
# It runs the same `check-english-usage` hook from pre-commit
# configuration to keep local checks aligned with CI behavior.

pre-commit run \
  --config scripts/config/pre-commit.yaml \
  check-english-usage \
  --all-files
