# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

TonTon (トントン) is a Flutter health tracking application focused on "Making health management fun with calorie savings" (カロリー貯金で健康管理を楽しく). The app uses AI-powered meal logging, integrates with iOS HealthKit, and implements a unique calorie savings concept.

## Essential Commands

```bash
# Environment Setup
cp .env.example .env
# Then edit .env with Supabase credentials

# Development
flutter run                                    # Run app in debug mode
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...  # Run with env vars

# Testing & Analysis
flutter test                                   # Run all tests
flutter analyze                                # Static analysis

# Build
flutter build ios                              # Build iOS app
flutter build apk                              # Build Android APK

# iOS Deployment
cd ios && bundle exec fastlane beta           # Deploy to TestFlight

# Component Catalog
flutter run -t widgetbook/main.dart -d chrome # View design system components
```

## Architecture

### Directory Structure
- `lib/features/` - Feature-based modules (health, meal_logging, profile, progress, etc.)
- `lib/design_system/` - Atomic design components (atoms, molecules, organisms, templates)
- `lib/core/` - Core providers and services
- `lib/models/` - Data models
- `lib/services/` - Business logic services

### State Management
Uses Riverpod providers throughout. Key providers:
- `userProfileProvider` - User profile state
- `mealLogProvider` - Meal logging state
- `weightHistoryProvider` - Weight tracking state
- `healthKitServiceProvider` - HealthKit integration

### Key Technologies
- **Backend**: Supabase (Edge Functions)
- **AI**: Google Generative AI (Gemini) for meal image analysis
- **Local Storage**: Hive for offline data
- **Routing**: go_router with AppShell structure
- **Localization**: Japanese/English support

## Critical Development Process

This project enforces **spec-driven development** for major changes:

1. **Automatic Triggers**: Keywords like リファクタリング, 新機能, 実装, 機能追加, バグ修正
2. **Required Phases**: Requirements → Design → Implementation Plan → Implementation
3. **Spec Location**: `.cckiro/specs/{task-name}/`
4. **Exceptions**: typo修正, 小さなバグ修正, コメント追加, ログ出力調整

## Current Development State

**Branch**: app-store-clean (targeting App Store submission)
**Version**: 1.0.1

**Active Work Areas**:
- Weight history integration (currently showing empty data)
- Profile screen completion (missing age/gender selection, logout)
- Auto PFC (protein/fat/carb) calculations

**Urgent Priorities**:
- GitHub Pages setup for privacy policy
- App Store review preparation
- Fix weight history data integration

## Key Implementation Notes

### AI Meal Logging
- Uses Gemini API for food image analysis
- Structured prompt in `lib/features/meal_logging/services/ai_meal_analyzer_service.dart`
- Returns calories, PFC breakdown, and meal insights

### Calorie Savings Concept
- Core feature: calories saved vs consumed
- Daily savings calculated as: base metabolism - consumed calories
- Visualized in progress screens with charts

### HealthKit Integration
- iOS only via `health` package
- Syncs weight data bidirectionally
- Requires Info.plist permissions

### Design System
- Custom theme with design tokens
- TontonIcons custom icon font
- Component hierarchy: atoms → molecules → organisms → templates
- Widgetbook for component documentation

## Common Tasks

### Adding a New Feature
1. Create feature directory under `lib/features/`
2. Implement providers, screens, and services
3. Update routes in `lib/routes/app_router.dart`
4. Add to AppShell if needed

### Modifying UI Components
1. Check design system in `lib/design_system/`
2. Use existing atoms/molecules when possible
3. Test in Widgetbook before integration

### Working with Providers
1. Define provider in feature's `providers/` directory
2. Use `ref.watch()` in widgets, `ref.read()` for actions
3. Dispose resources properly

## Testing Approach
- Unit tests in `/test/` directory
- No integration tests currently implemented
- GitHub Actions runs tests on PRs
- Manual testing required for HealthKit features