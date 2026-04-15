---
layout: page
title:  Run Git hooks on commit
parent: User Guides
description:  Run Git hooks on commit
summary:  Run Git hooks on commit
is_not_draft: false
last_modified_date: 2024-05-28
owner: Ross Buggins
author: Ross Buggins
---

## Guide: Run Git hooks on commit

- [Guide: Run Git hooks on commit](#guide-run-git-hooks-on-commit)
- [Overview](#overview)
- [Key files](#key-files)
- [Testing](#testing)

## Overview

Git hooks are managed through the [pre-commit](https://pre-commit.com/) framework and configured in [`scripts/config/pre-commit.yaml`](../../scripts/config/pre-commit.yaml). The hook implementations are consumed from `NHSDigital/nhs-notify-shared-modules` at a pinned ref and run locally and in CI for consistent checks.

The [pre-commit](https://pre-commit.com/) framework is a powerful tool for managing Git hooks, providing automated hook installation and management capabilities.

## Key files

- Configuration
  - [`pre-commit.yaml`](../../scripts/config/pre-commit.yaml)
  - [`check-todos-ignore.conf`](../../scripts/config/check-todos-ignore.conf)
  - [`stage-1-commit.yaml`](../../.github/workflows/stage-1-commit.yaml): CI workflow using shared-modules actions
  - [`init.mk`](../../scripts/init.mk): make targets

## Testing

You can run and test the process by executing the following commands from your terminal. These commands should be run from the top-level directory of the repository:

```shell
pre-commit run --config scripts/config/pre-commit.yaml --all-files
```
