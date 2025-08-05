# TonTon Project Documentation Index

## 📱 Project Overview

**TonTon (トントン)** is a SwiftUI health tracking application focused on "Making health management fun with calorie savings" (カロリー貯金で健康管理を楽しく). The app uses CloudKit for data synchronization, AI-powered meal logging, integrates with iOS HealthKit, and implements a unique calorie savings concept.

**Current Version**: 1.0+  
**Platform**: iOS (SwiftUI + CloudKit)  
**Status**: App Store ready

## 🏗️ Architecture Overview

### Core Technologies
- **Frontend**: SwiftUI with declarative UI
- **State Management**: SwiftData + SwiftUI reactive patterns
- **Backend**: CloudKit for data synchronization and storage
- **AI Integration**: Native Swift AI services for meal analysis
- **Local Storage**: SwiftData for offline-first architecture
- **Health Integration**: Native HealthKit framework
- **Navigation**: SwiftUI NavigationStack with AppShell
- **Charts**: SwiftUI Charts framework for data visualization

### Directory Structure
```
Tonton/Tonton/
├── Views/                  # SwiftUI views organized by feature
│   ├── Charts/            # Data visualization components
│   ├── Components/        # Reusable UI components
│   ├── HomeView.swift     # Main dashboard
│   ├── MealLoggingView.swift  # AI meal logging interface
│   ├── ProfileView.swift  # User profile management
│   ├── ProgressView.swift # Progress tracking & analytics
│   └── UnifiedSettingsView.swift  # App settings
├── Models/                 # SwiftData models
│   ├── UserProfile.swift  # User profile data model
│   ├── MealRecord.swift   # Meal logging data model
│   ├── WeightRecord.swift # Weight tracking data model
│   ├── CalorieSavingsRecord.swift  # Calorie savings data
│   └── DailySummary.swift # Daily summary aggregation
├── Services/              # Business logic services
│   ├── HealthKitService.swift  # HealthKit integration
│   ├── CloudKitService.swift   # CloudKit data sync
│   ├── AIServiceManager.swift  # AI meal analysis
│   └── DataService.swift      # Core data operations
├── Utilities/             # Helper functions and extensions
└── Assets.xcassets/       # App icons and visual assets
```

## 🔧 Development Setup

### Essential Commands
```bash
# Environment Setup
cp .env.example .env
# Edit .env with Supabase credentials

# Development
flutter run                 # Run in debug mode
flutter run -t widgetbook/main.dart -d chrome  # Component catalog

# Testing & Analysis
flutter test               # Run all tests
flutter analyze            # Static analysis

# Build & Deploy
flutter build ios          # iOS build
cd ios && bundle exec fastlane beta  # TestFlight deployment
```

### Environment Variables
Required in `.env` file:
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

## 📋 Feature Documentation

### Core Features

#### 🍽️ AI Meal Logging
- **Location**: `lib/features/meal_logging/`
- **Key Files**:
  - `ai/ai_meal_logging_step1_camera.dart` - Camera capture
  - `ai/ai_meal_logging_step2_analyzing.dart` - AI analysis
  - `ai/ai_meal_logging_step3_confirm_edit.dart` - Result confirmation
  - `services/ai_meal_analyzer_service.dart` - Gemini integration
- **Documentation**: [AI Integration Guide](docs/ai_integration_guide.md)

#### 📊 Health Integration
- **Location**: `lib/features/health/`
- **Key Files**:
  - `providers/weight_record_provider.dart` - Weight data management
  - `screens/weight_input_screen.dart` - Manual weight entry
- **Documentation**: [HealthKit Integration Guide](docs/healthkit_integration_guide.md)

#### 🎯 Calorie Savings System
- **Location**: `lib/features/savings/`
- **Core Concept**: Daily savings = base metabolism - consumed calories
- **Key Files**:
  - `providers/savings_balance_provider.dart` - Savings calculations
  - `screens/savings_trend_screen.dart` - Savings visualization

#### 📈 Progress Tracking
- **Location**: `lib/features/progress/`
- **Key Files**:
  - `screens/graphs_screen.dart` - Data visualization
  - `providers/pfc_balance_provider.dart` - Nutrition tracking

### Design System

#### Atomic Design Structure
- **Atoms**: `lib/design_system/atoms/` - Basic components (TontonButton, TontonText, TontonIcon)
- **Molecules**: `lib/design_system/molecules/` - Composed components (cards, charts, displays)
- **Organisms**: `lib/design_system/organisms/` - Complex sections (summary sections, stats displays)
- **Templates**: `lib/design_system/templates/` - Page layouts (AppShell, StandardPageLayout)

#### Component Catalog
```bash
flutter run -t widgetbook/main.dart -d chrome
```
Browse all UI components, test different states, and preview themes.

## 📚 Key Documentation

### Development Guides
- [Environment Setup Guide](docs/env_setup_guide.md)
- [Hive Persistence Guide](docs/HIVE_PERSISTENCE_GUIDE.md)
- [Icon Font Guide](docs/ICON_FONT.md)

### AI & Integration
- [AI Integration Guide](docs/ai_integration_guide.md)
- [AI Image Analysis Guide](docs/ai_image_analysis_guide.md)
- [HealthKit Integration Guide](docs/healthkit_integration_guide.md)

### Project Status
- [Release Notes](docs/RELEASE_NOTES.md)
- [Roadmap](docs/ROADMAP.md)
- [TODO List](docs/TODO.md)
- [App Store Checklist](docs/APP_STORE_CHECKLIST.md)

### Troubleshooting
- [Hive Debug Guide](docs/HIVE_DEBUG_GUIDE.md)
- [AI Advice Troubleshooting](docs/AI_ADVICE_TROUBLESHOOTING.md)

## ⚡ State Management

### Riverpod Providers Architecture
- **Core Providers**: `lib/core/providers/`
  - `auth_provider.dart` - Authentication state
  - `health_provider.dart` - HealthKit integration
  - `user_weight_provider.dart` - Weight data management
- **Feature Providers**: Located within each feature module
- **Provider Index**: Each feature has `providers/index.dart` for exports

### Key Provider Patterns
```dart
// Provider definition
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>(...);

// Usage in widgets
final profile = ref.watch(userProfileProvider);  // Watch for rebuilds
ref.read(userProfileProvider.notifier).updateProfile(...);  // Actions
```

## 🔄 Data Flow

### Local Storage (Hive)
- **Meal Records**: `tonton_meal_records` box
- **Daily Summaries**: `tonton_daily_summaries` box
- **Adapters**: Auto-generated for custom models

### Remote Storage (Supabase)
- **Authentication**: Built-in Supabase auth
- **Edge Functions**: AI meal analysis processing
- **Real-time Updates**: Supabase real-time subscriptions

### HealthKit Integration
- **Bidirectional Sync**: Weight data sync between app and HealthKit
- **iOS Only**: Android uses manual input only
- **Permissions**: Configured in `ios/Runner/Info.plist`

## 🎨 Theming & Design

### Design Tokens
- **Location**: `lib/theme/`
- **Key Files**:
  - `tokens.dart` - Design tokens (colors, spacing, typography)
  - `colors.dart` - Color palette definitions
  - `typography.dart` - Text styles and font configurations
  - `app_theme.dart` - Complete theme assembly

### Custom Assets
- **Fonts**: Noto Sans JP (multiple weights) + TontonIcons (custom icon font)
- **Icons**: Custom SVG icons in `assets/icons/svg/`
- **Localization**: Japanese/English support

## 🚀 Build & Deployment

### iOS Deployment
```bash
cd ios
bundle exec fastlane beta  # TestFlight deployment
```

### Key Build Files
- `pubspec.yaml` - Dependencies and assets
- `ios/Fastfile` - iOS deployment automation
- `.env` - Environment configuration (not in repo)

## 🧪 Testing

### Current Testing Setup
- **Unit Tests**: `/test/` directory
- **Integration Tests**: Basic setup (limited coverage)
- **Manual Testing**: Required for HealthKit features
- **CI/CD**: GitHub Actions runs tests on PRs

### Testing Commands
```bash
flutter test           # Run all tests
flutter analyze        # Static analysis
```

## 🔍 Development Status

### Current Focus (v1.0.1)
- **App Store Submission**: Preparing for iOS App Store
- **Weight History Integration**: Fixing empty data display
- **Profile Completion**: Age/gender selection, logout functionality
- **Auto PFC Calculations**: Protein/Fat/Carb recommendations

### Known Issues
- Weight history showing empty data
- Missing profile completion features
- GitHub Pages setup needed for privacy policy

### Next Priorities
1. Complete App Store submission preparation
2. Fix weight history data integration  
3. Implement missing profile features
4. Set up privacy policy hosting

## 📖 Code Conventions

### File Organization
- Feature-based directory structure
- Provider pattern for state management
- Atomic design for UI components
- Service layer for business logic

### Naming Conventions
- **Files**: snake_case for Dart files
- **Classes**: PascalCase
- **Variables/Functions**: camelCase
- **Constants**: SCREAMING_SNAKE_CASE

### Import Organization
```dart
// Flutter imports
import 'package:flutter/material.dart';

// Third-party imports
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Local imports
import '../models/user_profile.dart';
import '../services/health_service.dart';
```

## 🔗 Quick Navigation

### Most Important Files
- [`lib/main.dart`](lib/main.dart) - App entry point
- [`lib/design_system/templates/app_shell.dart`](lib/design_system/templates/app_shell.dart) - App shell navigation
- [`lib/features/home/screens/home_screen.dart`](lib/features/home/screens/home_screen.dart) - Main dashboard
- [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart) - Application theming
- [`CLAUDE.md`](CLAUDE.md) - Claude Code development instructions

### Key Configuration Files
- [`pubspec.yaml`](pubspec.yaml) - Dependencies and project config
- [`ios/Fastfile`](ios/Fastfile) - iOS deployment automation
- [`.env.example`](.env.example) - Environment variable template

---

**Last Updated**: January 2025  
**Maintained by**: TonTon Development Team  
**For Claude Code**: See [CLAUDE.md](CLAUDE.md) for development guidance