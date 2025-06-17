#!/bin/bash
# Script to run Match with explicit git_url to avoid parsing issues

echo "Running Fastlane Match for development certificates..."
bundle exec fastlane match development --git_url "https://github.com/DELAxGithub/tonton-match.git"