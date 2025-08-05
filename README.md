# TonTon

A SwiftUI health tracking application with CloudKit integration, focused on "Making health management fun with calorie savings" (カロリー貯金で健康管理を楽しく).

## Technology Stack

- **Frontend:** SwiftUI, SwiftData
- **Backend:** CloudKit
- **AI Integration:** Native Swift AI services
- **Local Storage:** SwiftData, CloudKit
- **Health Integration:** iOS HealthKit

## Getting Started

### Prerequisites

- **Xcode 15.0+** with iOS 17.0+ SDK
- **Apple Developer Account** for CloudKit setup
- **iOS Device or Simulator** for testing HealthKit integration

### Development Setup

1. Open the Xcode project:
   ```bash
   open Tonton/Tonton.xcodeproj
   ```

2. Configure CloudKit:
   - Enable CloudKit capability in your app
   - Set up CloudKit container in Apple Developer portal
   - Configure data models in CloudKit Dashboard

3. Build and run:
   - Select target device or simulator
   - Build and run the project (⌘+R)

### HealthKit Integration Setup

The app integrates with iOS HealthKit for weight and activity data. Ensure:
- HealthKit permissions are configured in Info.plist
- Test on physical device (HealthKit not available in simulator)
## Core Features

**Calorie Savings System**
- Unique calorie savings concept: track daily savings vs consumption
- Visual progress tracking with charts and statistics
- Motivational piggy bank metaphor for health management

**AI-Powered Meal Logging**
- Camera-based meal recognition and calorie estimation
- Nutritional breakdown (protein, fat, carbohydrates)
- Smart meal analysis with native Swift AI integration

**Health Integration**
- Seamless HealthKit integration for weight and activity data
- Bidirectional data sync between app and Apple Health
- Real-time health metrics monitoring

**CloudKit Backend**
- Secure data synchronization across devices
- Offline-first architecture with CloudKit sync
- Privacy-focused data handling with Apple's ecosystem

## Build & Deployment

### iOS App Store Deployment

Build and deploy to App Store using Xcode:

1. **Archive the app**: Product → Archive in Xcode
2. **Upload to App Store Connect**: Use Xcode Organizer or Transporter
3. **Submit for Review**: Configure app metadata in App Store Connect

### TestFlight Distribution

For beta testing:
1. Archive and upload to App Store Connect
2. Add internal/external testers in TestFlight
3. Distribute builds for testing

## Project Architecture

### SwiftUI + SwiftData Stack
- **Views**: Declarative UI with SwiftUI
- **Data Layer**: SwiftData for local persistence
- **Networking**: CloudKit for synchronization
- **Services**: Native Swift services for AI and health integration

### Key Components
- **Models**: SwiftData models for core entities (UserProfile, MealRecord, WeightRecord)
- **Views**: Modular SwiftUI views organized by feature
- **Services**: Business logic services (HealthKit, CloudKit, AI)
- **Utilities**: Helper functions and extensions

## Documentation

### Project Status
- [Release Notes](docs/RELEASE_NOTES.md)
- [Roadmap](docs/ROADMAP.md) 
- [TODO List](docs/TODO.md)
- [App Store Checklist](docs/APP_STORE_CHECKLIST.md)

### Deployment
- [App Store Submission](docs/app_store_submission_draft.md)
- [Privacy Policy](docs/privacy-policy.md)

