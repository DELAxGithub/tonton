# Fastlane Setup Guide for TonTon

This guide walks through setting up Fastlane for automated iOS builds and deployments.

## Prerequisites

Before starting, ensure you have:

- [x] Xcode command line tools: `xcode-select --install`
- [x] Ruby 2.5 or higher: `ruby --version`
- [x] Bundler: `gem install bundler`
- [ ] Apple Developer account with proper permissions
- [ ] Access to App Store Connect

## Initial Setup

### 1. Install Fastlane

Navigate to the iOS directory and install dependencies:

```bash
cd ios
bundle install --path vendor/bundle
```

### 2. Environment Configuration

Create your environment file from the template:

```bash
cp fastlane/.env.default fastlane/.env
```

Edit `fastlane/.env` with your credentials:

```bash
# Required
APPLE_ID="your.email@example.com"
TEAM_ID="XXXXXXXXXX"  # Found in Apple Developer Portal
ITC_TEAM_ID="XXXXXXXX"  # Found in App Store Connect

# For Match (code signing)
MATCH_GIT_URL="https://github.com/YOUR_ORG/certificates.git"
MATCH_PASSWORD="your-secure-password"

# Optional but recommended
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

### 3. App Store Connect API Key (Recommended)

For CI/CD and to avoid 2FA issues:

1. Go to App Store Connect > Users and Access > Keys
2. Create a new API key with "App Manager" role
3. Download the .p8 file
4. Add to your .env:

```bash
APP_STORE_CONNECT_API_KEY_ID="XXXXXXXXXX"
APP_STORE_CONNECT_API_ISSUER_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
APP_STORE_CONNECT_API_KEY_CONTENT="$(cat ~/path/to/AuthKey_XXXXXXXXXX.p8 | base64)"
```

## Code Signing with Match

Match manages your certificates and provisioning profiles in a git repository.

### 1. Create Certificates Repository

Create a **private** GitHub repository for storing certificates:
- Name: `certificates` or `ios-certificates`
- Visibility: Private
- Initialize with README

### 2. Configure Match

Update `ios/fastlane/Matchfile` with your repository URL:

```ruby
git_url("https://github.com/YOUR_ORG/certificates")
app_identifier(["com.example.tonton"])  # Your actual bundle ID
```

### 3. Initialize Match

First time setup (requires Apple Developer admin access):

```bash
cd ios
bundle exec fastlane match init
```

### 4. Generate Certificates

Create new certificates and profiles:

```bash
# Development certificates (for local builds)
bundle exec fastlane match development

# Distribution certificates (for TestFlight/App Store)
bundle exec fastlane match appstore
```

### 5. Use Existing Certificates

If certificates already exist:

```bash
bundle exec fastlane match development --readonly
bundle exec fastlane match appstore --readonly
```

## Xcode Configuration

### 1. Automatic Code Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Uncheck "Automatically manage signing"
5. Select the Match provisioning profiles:
   - Debug: `match Development com.example.tonton`
   - Release: `match AppStore com.example.tonton`

### 2. Build Settings

Ensure these settings in Xcode:
- Bundle Identifier matches your App ID
- Team is correctly selected
- Deployment target matches your requirements

## Usage

### Daily Development

```bash
# Download latest certificates
cd ios
bundle exec fastlane certificates

# Run tests
bundle exec fastlane test
```

### Release Process

```bash
# 1. Ensure clean git status
git status

# 2. Build and upload to TestFlight
cd ios
bundle exec fastlane beta

# This will automatically:
# - Increment build number
# - Build the app
# - Upload to TestFlight
# - Commit version changes
# - Create git tag
```

### Version Management

```bash
# Increment versions
bundle exec fastlane bump_version type:patch  # 1.0.0 -> 1.0.1
bundle exec fastlane bump_version type:minor  # 1.0.0 -> 1.1.0
bundle exec fastlane bump_version type:major  # 1.0.0 -> 2.0.0
```

## CI/CD Setup

### GitHub Actions Example

Create `.github/workflows/ios-deploy.yml`:

```yaml
name: Deploy to TestFlight

on:
  push:
    branches: [main]
    paths:
      - 'lib/**'
      - 'ios/**'
      - 'pubspec.yaml'

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.2'
          
      - name: Install dependencies
        run: |
          flutter pub get
          cd ios && bundle install
          
      - name: Setup certificates
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
        run: |
          cd ios
          bundle exec fastlane match appstore --readonly
          
      - name: Build and deploy
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY_CONTENT }}
        run: |
          cd ios
          bundle exec fastlane beta
```

## Best Practices

### Security

1. **Never commit sensitive data**:
   - `.env` files
   - `.p8` key files
   - Certificates

2. **Use environment variables** for all secrets

3. **Rotate Match password** periodically

4. **Limit access** to certificates repository

### Team Collaboration

1. **Read-only by default**: New team members should use `--readonly` flag

2. **Document your setup**: Keep README updated with team-specific info

3. **Version control**: Commit `Fastfile` changes with descriptive messages

4. **Communicate releases**: Notify team when deploying to TestFlight

### Troubleshooting Tips

1. **Certificate issues**: Run `fastlane match nuke` to reset (careful!)

2. **Build failures**: Check `ios/fastlane/test_output` for detailed logs

3. **2FA problems**: Use App Store Connect API keys instead of passwords

4. **Keychain access**: On CI, create temporary keychain

## Screenshot Automation

Generate App Store screenshots automatically:

```bash
# Generate screenshots for all languages and devices
cd ios
bundle exec fastlane screenshots

# Upload screenshots to App Store Connect
bundle exec fastlane create_app_store_screenshots

# Generate screenshots and deploy to TestFlight
bundle exec fastlane beta_with_screenshots
```

See [Screenshot Guidelines](screenshot_guidelines.md) for detailed setup and maintenance instructions.

## Next Steps

1. Configure Slack notifications (optional)
2. ~~Set up screenshot automation~~ ✓ Complete
3. Implement staged rollouts
4. Add crash reporting integration

For more information, see:
- [Fastlane Documentation](https://docs.fastlane.tools)
- [Match Documentation](https://docs.fastlane.tools/actions/match/)
- [CI/CD Best Practices](https://docs.fastlane.tools/best-practices/continuous-integration/)
- [Screenshot Guidelines](screenshot_guidelines.md)