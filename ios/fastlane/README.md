fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Create screenshots

### ios create_app_store_screenshots

```sh
[bundle exec] fastlane ios create_app_store_screenshots
```

Create localized App Store screenshots

### ios beta_with_screenshots

```sh
[bundle exec] fastlane ios beta_with_screenshots
```

Build, screenshot, and deploy to TestFlight

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests

### ios certificates

```sh
[bundle exec] fastlane ios certificates
```

Download certificates and profiles

### ios create_certificates

```sh
[bundle exec] fastlane ios create_certificates
```

Create new certificates and profiles

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

Increment version number

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
