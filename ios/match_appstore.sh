#!/bin/bash
# Script to run Match with explicit git_url to avoid parsing issues

echo "Running Fastlane Match for App Store certificates..."
bundle exec fastlane match appstore --git_url "https://github.com/DELAxGithub/tonton-match.git"