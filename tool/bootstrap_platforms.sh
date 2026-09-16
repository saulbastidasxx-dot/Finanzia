#!/usr/bin/env bash
set -euo pipefail
platforms="${1:-android,web}"
# Generate only missing Flutter runners in CI/development environments.
# flutter create preserves lib/, test/, assets/ and project sources.
flutter create . --platforms="$platforms" --project-name finanzia --org app.finanzia
