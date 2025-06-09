# Fastlane for TonTon iOS

This directory contains the Fastlane configuration for automating iOS builds and deployments.

## Setup

### 1. Install Fastlane

```bash
cd ios
bundle install
```

If you haven't installed bundler:
```bash
gem install bundler
```

### 2. Configure Environment Variables

Copy the default environment file and fill in your values:

```bash
cp fastlane/.env.default fastlane/.env
```

Edit `.env` with your Apple Developer credentials and other settings.

### 3. Set up Code Signing (Match)

Initialize Match with your certificates repository:

```bash
bundle exec fastlane match init
```

Then download existing certificates or create new ones:

```bash
# Download existing certificates (recommended)
bundle exec fastlane certificates

# Or create new certificates (requires admin access)
bundle exec fastlane create_certificates
```

## Available Lanes

### Beta Release

Build and upload to TestFlight:

```bash
bundle exec fastlane beta
```

This will:
1. Check git status is clean
2. Increment build number
3. Sync certificates via Match
4. Build the app
5. Upload to TestFlight
6. Commit version changes
7. Tag the release
8. Push to git

### Run Tests

```bash
bundle exec fastlane test
```

### Create Screenshots

```bash
bundle exec fastlane screenshots
```

### Increment Version

```bash
# Increment patch version (1.0.0 -> 1.0.1)
bundle exec fastlane bump_version type:patch

# Increment minor version (1.0.0 -> 1.1.0)
bundle exec fastlane bump_version type:minor

# Increment major version (1.0.0 -> 2.0.0)
bundle exec fastlane bump_version type:major
```

## CI/CD Integration

For GitHub Actions or other CI systems:

1. Set up environment variables as secrets
2. Create a temporary keychain for certificates
3. Use the read-only mode for Match

Example GitHub Actions step:

```yaml
- name: Build and Deploy to TestFlight
  env:
    APPLE_ID: ${{ secrets.APPLE_ID }}
    TEAM_ID: ${{ secrets.TEAM_ID }}
    MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
    MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
  run: |
    cd ios
    bundle exec fastlane beta
```

## Troubleshooting

### Code Signing Issues

If you encounter code signing errors:
1. Ensure your Apple ID has proper access
2. Check that Match repository is accessible
3. Try running with `--verbose` flag
4. Clear derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Build Failures

1. Clean build folder: `flutter clean`
2. Update pods: `cd ios && pod update`
3. Check Xcode project settings match Fastlane config

### Match Issues

If Match can't find or create certificates:
1. Verify git repository access
2. Check Apple Developer Portal for existing certificates
3. Ensure proper team selection in Xcode

## Security Notes

- Never commit `.env` file
- Use App Store Connect API keys instead of password for CI
- Rotate Match password regularly
- Use separate certificates repository with restricted access