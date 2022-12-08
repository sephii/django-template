#!/usr/bin/env bash
set -e

./scripts/check_migrations.sh
pytest "${@:-{{ cookiecutter.project_slug }}}"
