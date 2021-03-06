#!/usr/bin/env bash
set -euf -o pipefail

SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SELF_DIR/.."

source "$SELF_DIR/common.sh"

assertPython


echo
echo "===Setting up venv==="
enterVenv


echo
echo "===Installing poetry==="
pip install poetry


echo
echo "===Installing dependencies==="
poetry install


echo
echo "===Sorting imports==="
ISORT_ARGS="--apply"
if [[ "${CI:-}" = "1" ]]; then
  ISORT_ARGS="--check-only"
fi

isort $ISORT_ARGS


echo
echo "===Formatting code==="
BLACK_ARGS=""
if [[ "${CI:-}" = "1" ]]; then
  BLACK_ARGS="--check"
fi

black $BLACK_ARGS .


echo
echo "===Lint with bandit==="
bandit \
  --recursive \
  --exclude '**/__pycache__/*' \
  ./withings_api


echo
echo "===Lint with codespell==="
codespell \
  --check-filenames \
  --ignore-words ./.codespell-ignore \
  --skip "*/__pycache__/*" \
  ./withings_api ./test ./scripts


echo
echo "===Lint with flake8==="
flake8


echo
echo "===Lint with mypy==="
mypy .


echo
echo "===Lint with pylint==="
pylint $LINT_PATHS


echo
echo "===Test with pytest==="
pytest


echo
echo "===Building package==="
poetry build


echo
echo "Build complete"
