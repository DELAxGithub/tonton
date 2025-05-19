# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TonTon is a health tracking application with a focus on iOS HealthKit integration. The app demonstrates Flutter's ability to interact with iOS HealthKit to retrieve health data including:
- Workout activities and calories
- Daily calorie consumption (active and basal)
- Weight records
- Body fat percentage

## Repository Structure

- `health_poc_app/`: Proof of Concept Flutter application demonstrating HealthKit integration
- `lib/`: Core application code
  - `models/`: Data models for health information
  - `services/`: Service classes like HealthService for abstracting HealthKit interactions
  - `utils/`: Utility functions

## Development Commands

### Setup

```bash
# Install dependencies
cd health_poc_app
flutter pub get
```

### Running the App

```bash
# Run on connected iOS device (HealthKit requires iOS physical device)
cd health_poc_app
flutter run
```

### Running Tests

```bash
# Run unit tests
cd health_poc_app
flutter test
```

## iOS Configuration Requirements

The app requires specific iOS configuration for HealthKit:

1. HealthKit capability must be added to the iOS project
2. `Info.plist` must include privacy descriptions:
   - `NSHealthShareUsageDescription`
   - `NSHealthUpdateUsageDescription`

## Health Data Integration

- The app uses the `health` package (^12.2.0) to interact with HealthKit
- Implementation requires:
  1. Requesting appropriate permissions with `requestAuthorization()`
  2. Fetching data with `getHealthDataFromTypes()`
  3. Processing results into app-specific data models

## Important Notes

- HealthKit testing requires iOS physical devices with HealthKit data
- HealthKit data requires explicit user permission for every data type
- Workout activity types from HealthKit need custom formatting for display