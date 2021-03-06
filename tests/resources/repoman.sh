#!/usr/bin/env bash
# "Lint" using repoman if any ebuilds have basic issues
# In case of a PR the result is added as a comment to the PR
set -ex

# Disable news messages from portage and disable rsync's output
export FEATURES="-news" PORTAGE_RSYNC_EXTRA_OPTS="-q"

# Install dependencies
emerge -q --buildpkg --usepkg dev-vcs/git app-portage/repoman dev-python/pip
pip install --user https://github.com/simonvanderveldt/travis-github-pr-bot/archive/master.zip
PATH="~/.local/bin:$PATH"

# Run the tests
if ! repoman_output=$(repoman full -d -q); then
  echo "$repoman_output"
  # Don't report back to GitHub for third-party pull requests
  # This is to prevent build failures because the required encrypted env vars are missing for 3rd party PRs
  if [[ "$TRAVIS_SECURE_ENV_VARS" == "true" ]]; then
    echo "$repoman_output" | travis-bot --description "Repoman QA results:"
  else
    echo "Skipping posting repoman QA results to GitHub because TRAVIS_SECURE_ENV_VARS is not 'true'"
  fi
  exit 1
else
  echo "$repoman_output"
  # Don't report back to GitHub for third-party pull requests
  # This is to prevent build failures because the required encrypted env vars are missing for 3rd party PRs
  if [[ "$TRAVIS_SECURE_ENV_VARS" == "true" ]]; then
    echo "$repoman_output" | travis-bot --description "Repoman QA results:"
  else
    echo "Skipping posting repoman QA results to GitHub because TRAVIS_SECURE_ENV_VARS is not 'true'"
  fi
fi
