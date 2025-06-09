# Fastlane Troubleshooting Guide

Common issues and solutions for Fastlane with TonTon iOS app.

## Installation Issues

### Bundle Install Fails

**Problem**: `bundle install` requires sudo or fails with permission errors

**Solution**:
```bash
# Install to local directory
bundle config set --local path 'vendor/bundle'
bundle install

# Or use rbenv/rvm for Ruby version management
rbenv install 3.0.0
rbenv local 3.0.0
```

### Fastlane Command Not Found

**Problem**: `fastlane: command not found` after installation

**Solution**:
```bash
# Use bundle exec
bundle exec fastlane [command]

# Or add to PATH
export PATH="$PATH:./vendor/bundle/bin"
```

## Code Signing Issues

### Match Can't Access Repository

**Problem**: "Authentication failed for git repository"

**Solutions**:
1. Use HTTPS with personal access token:
   ```bash
   MATCH_GIT_URL="https://YOUR_TOKEN@github.com/org/certificates.git"
   ```

2. Configure SSH:
   ```bash
   ssh-add ~/.ssh/id_rsa
   git ls-remote git@github.com:org/certificates.git
   ```

### Certificate Not Found

**Problem**: "No matching provisioning profiles found"

**Solutions**:
1. Regenerate certificates:
   ```bash
   bundle exec fastlane match nuke appstore
   bundle exec fastlane match appstore
   ```

2. Clear Xcode cache:
   ```bash
   rm -rf ~/Library/MobileDevice/Provisioning\ Profiles
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

### Keychain Issues on CI

**Problem**: "User interaction is not allowed" on CI

**Solution**:
```ruby
# In Fastfile, before match:
create_keychain(
  name: "ci_keychain",
  password: ENV["KEYCHAIN_PASSWORD"],
  default_keychain: true,
  unlock: true,
  timeout: 3600
)

match(
  keychain_name: "ci_keychain",
  keychain_password: ENV["KEYCHAIN_PASSWORD"],
  readonly: true
)
```

## Build Issues

### Flutter Build Fails

**Problem**: "Module 'Runner' not found"

**Solutions**:
1. Clean and rebuild:
   ```bash
   flutter clean
   cd ios
   pod deintegrate
   pod install
   flutter build ios
   ```

2. Check Flutter version:
   ```bash
   flutter doctor -v
   flutter upgrade
   ```

### Archive Fails

**Problem**: "No profiles for 'com.example.tonton' were found"

**Solutions**:
1. Verify bundle ID matches:
   - Check `ios/Runner.xcodeproj/project.pbxproj`
   - Check `ios/fastlane/Appfile`
   - Check App Store Connect

2. Refresh profiles:
   ```bash
   bundle exec fastlane match appstore --force_for_new_devices
   ```

## TestFlight Upload Issues

### API Key Authentication Fails

**Problem**: "Invalid API key"

**Solution**:
```bash
# Verify key format
echo $APP_STORE_CONNECT_API_KEY_CONTENT | base64 -d

# Should show:
# -----BEGIN PRIVATE KEY-----
# ...
# -----END PRIVATE KEY-----
```

### Build Processing Stuck

**Problem**: Build uploaded but not processing

**Solutions**:
1. Check App Store Connect for errors
2. Ensure export compliance is set:
   ```xml
   <!-- In ios/Runner/Info.plist -->
   <key>ITSAppUsesNonExemptEncryption</key>
   <false/>
   ```

### Missing dSYM Files

**Problem**: "Missing dSYM files" warning

**Solution**:
```ruby
# In Fastfile:
upload_symbols_to_crashlytics(
  dsym_path: "./Runner.app.dSYM.zip"
)
```

## Version Management Issues

### Git Working Directory Not Clean

**Problem**: "Git repository is not clean"

**Solutions**:
1. Commit or stash changes:
   ```bash
   git add .
   git commit -m "WIP"
   # or
   git stash
   ```

2. Skip git check (not recommended):
   ```ruby
   ensure_git_status_clean(show_diff: true)
   ```

### Version Already Exists

**Problem**: "This build number has already been used"

**Solution**:
```bash
# Force increment build number
cd ios
bundle exec fastlane run increment_build_number build_number:123
```

## Environment Issues

### Environment Variables Not Loading

**Problem**: ENV values are nil

**Solutions**:
1. Check .env file location:
   ```bash
   ls -la ios/fastlane/.env
   ```

2. Load manually in Fastfile:
   ```ruby
   Dotenv.load('../fastlane/.env')
   ```

### Two-Factor Authentication

**Problem**: Keeps asking for 2FA code

**Solutions**:
1. Use App-Specific Password:
   ```bash
   export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
   ```

2. Use API Key (recommended):
   ```ruby
   app_store_connect_api_key(
     key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
     issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
     key_content: ENV["APP_STORE_CONNECT_API_KEY_CONTENT"]
   )
   ```

## Performance Issues

### Slow Certificate Download

**Problem**: Match takes forever to clone repository

**Solution**:
```ruby
# In Matchfile:
shallow_clone(true)
clone_branch_directly(true)
```

### Build Takes Too Long

**Solutions**:
1. Use derived data path:
   ```ruby
   build_app(
     derived_data_path: "./build/DerivedData"
   )
   ```

2. Skip unnecessary steps:
   ```ruby
   skip_docs: true,
   skip_codesigning: false
   ```

## Debugging Tips

### Enable Verbose Logging

```bash
bundle exec fastlane [lane] --verbose
```

### Check Fastlane Environment

```bash
bundle exec fastlane env
```

### Test Individual Actions

```bash
# Test match
bundle exec fastlane run match type:appstore readonly:true

# Test build
bundle exec fastlane run build_app workspace:Runner.xcworkspace

# Test upload
bundle exec fastlane run upload_to_testflight
```

### Common Log Locations

- Build logs: `ios/fastlane/test_output/`
- Gym logs: `~/Library/Logs/gym/`
- Match logs: Check verbose output

## Getting Help

1. Check error message carefully
2. Run with `--verbose` flag
3. Check [Fastlane Issues](https://github.com/fastlane/fastlane/issues)
4. Ask on [Fastlane Discussions](https://github.com/fastlane/fastlane/discussions)

## Emergency Procedures

### Reset Everything

```bash
# Nuclear option - removes all certificates
bundle exec fastlane match nuke development
bundle exec fastlane match nuke appstore

# Recreate
bundle exec fastlane match development
bundle exec fastlane match appstore
```

### Manual TestFlight Upload

If automation fails:
1. Build with Flutter: `flutter build ios`
2. Open in Xcode: `open ios/Runner.xcworkspace`
3. Product > Archive
4. Upload via Xcode Organizer