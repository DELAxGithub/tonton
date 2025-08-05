# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

TonTon (トントン) is a SwiftUI health tracking application focused on "Making health management fun with calorie savings" (カロリー貯金で健康管理を楽しく). The app uses CloudKit for data synchronization, AI-powered meal logging, integrates with iOS HealthKit, and implements a unique calorie savings concept.

## Essential Commands

```bash
# Development
open Tonton/Tonton.xcodeproj                   # Open Xcode project
xcodebuild -project Tonton/Tonton.xcodeproj -scheme Tonton build  # Build from command line

# Testing
xcodebuild test -project Tonton/Tonton.xcodeproj -scheme Tonton -destination 'platform=iOS Simulator,name=iPhone 15'

# Archive & Deploy
xcodebuild archive -project Tonton/Tonton.xcodeproj -scheme Tonton -archivePath ./build/Tonton.xcarchive
```

## Architecture

### Directory Structure
- `Tonton/Tonton/Views/` - SwiftUI views organized by feature
- `Tonton/Tonton/Models/` - SwiftData models for core entities
- `Tonton/Tonton/Services/` - Business logic services
- `Tonton/Tonton/Utilities/` - Helper functions and extensions

### State Management
Uses SwiftUI + SwiftData for reactive state management:
- `@Model` classes for data persistence
- `@ObservableObject` for view models
- `@Environment` for dependency injection
- `@Query` for SwiftData queries

### Key Technologies
- **Backend**: CloudKit for data synchronization
- **AI**: Native Swift AI services for meal analysis
- **Local Storage**: SwiftData for offline-first architecture
- **Navigation**: SwiftUI NavigationStack with AppShell
- **Health Integration**: HealthKit framework

## Critical Development Process

This project enforces **spec-driven development** for major changes:

1. **Automatic Triggers**: Keywords like リファクタリング, 新機能, 実装, 機能追加, バグ修正
2. **Required Phases**: Requirements → Design → Implementation Plan → Implementation
3. **Spec Location**: `.cckiro/specs/{task-name}/`
4. **Exceptions**: typo修正, 小さなバグ修正, コメント追加, ログ出力調整

## Current Development State

**Platform**: iOS (SwiftUI)
**Version**: 1.0+

**Core Features Implemented**:
- CloudKit data synchronization
- HealthKit integration for weight and activity data
- AI-powered meal logging with camera integration
- Calorie savings tracking system
- SwiftUI-based user interface

**App Store Readiness**:
- Privacy policy setup
- App Store metadata preparation
- CloudKit container configuration

## Key Implementation Notes

### AI Meal Logging
- Native Swift AI services for food image analysis
- Camera integration with `AVFoundation`
- Returns calories, PFC breakdown, and meal insights
- Integrated with SwiftData for meal record persistence

### Calorie Savings Concept
- Core feature: calories saved vs consumed
- Daily savings calculated as: base metabolism - consumed calories
- Visualized with SwiftUI Charts framework
- Real-time updates with CloudKit synchronization

### HealthKit Integration
- Native HealthKit framework integration
- Syncs weight and activity data bidirectionally
- Requires HealthKit entitlements and Info.plist permissions
- Background health data updates

### CloudKit Backend
- SwiftData models with CloudKit sync
- Offline-first architecture with automatic sync
- User privacy with CloudKit private database
- Cross-device data consistency

## Common Tasks

### Adding a New SwiftUI View
1. Create new view file in `Tonton/Tonton/Views/`
2. Implement SwiftUI view with proper state management
3. Add navigation integration in AppShell
4. Update data models if needed

### Working with SwiftData Models
1. Define `@Model` classes in `Tonton/Tonton/Models/`
2. Configure CloudKit sync attributes
3. Use `@Query` in views for data fetching
4. Handle data relationships and migrations

### CloudKit Integration
1. Configure CloudKit schema in Developer portal
2. Add CloudKit capability to app target
3. Set up data model relationships
4. Test sync across multiple devices

## Testing Approach
- XCTest framework for unit and integration tests
- UI tests for critical user workflows
- Physical device testing required for HealthKit
- CloudKit testing in development and production environments