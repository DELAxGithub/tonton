# TonTon

A health tracking application with iOS HealthKit integration.

## Technology Stack

- **Frontend:** Flutter, Riverpod (state management)
- **Backend:** Supabase (Edge Functions)
- **AI Integration:** OpenAI API (GPT-4 model)
- **Local Storage:** Hive, SharedPreferences
- **Health Integration:** iOS HealthKit

## Getting Started

### 環境変数の設定

1. `.env.example`ファイルをコピーして`.env`ファイルを作成:
   ```bash
   cp .env.example .env
   ```

2. `.env`ファイルを編集し、必要な認証情報を設定:
   ```plaintext
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

詳細な設定手順は[環境変数の設定ガイド](docs/env_setup_guide.md)を参照してください。

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

See [docs/ICON_FONT.md](docs/ICON_FONT.md) for instructions on generating the custom icon font.

### UI Component Catalog (Widgetbook)

```bash
flutter run -t widgetbook/main.dart -d chrome
```

Browse all UI components, test different states, and preview themes. See [Widgetbook Guide](docs/design_system/widgetbook_guide.md) for details.

### Environment Variables

The app requires Supabase credentials to run. Set these variables in your shell
or pass them at build time:

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
```

These values are read in `lib/main.dart` and test scripts via
`Platform.environment`/`String.fromEnvironment`.
## Development Progress

The following milestones summarize the main features implemented so far:

- Custom design system with theme, design tokens, and icon fonts.
- Atom widgets such as **TontonIcon** and **TontonText**.
- Molecules like **TontonButton** and **TontonCardBase**, showcased in Dashbook.
- Dashbook UI catalog set up for rapid component previews.
- Integration with Supabase for backend services and Edge Functions.
- HealthKit integration on iOS.
- Navigation structure using **go_router** with an AppShell and profile screen.
- Home screen layout with daily stats ring and PFC bar display.
- AI meal logging flow powered by the Gemini-based image analysis service.
- Progress and achievements screen to track user goals.

These features establish the core architecture and primary screens of the TonTon application, providing a solid foundation for further development.

## Build & Deployment

### iOS Deployment with Fastlane

Automated iOS builds and TestFlight deployment:

```bash
cd ios
bundle exec fastlane beta
```

See [Fastlane Setup Guide](docs/deployment/fastlane_setup.md) for configuration details.

### Component Documentation

View the live component catalog at: [Coming Soon - GitHub Pages]

Or run locally:
```bash
flutter run -t widgetbook/main.dart -d chrome
```

## Documentation

### Development
- [Environment Setup](docs/env_setup_guide.md)
- [Engineering Handover](docs/handover/v1.0.0_engineering_handover.md)

### Design System
- [Widgetbook Component Catalog](https://YOUR_ORG.github.io/codex2-master-widgetbook/) *(Live URL coming soon)*
- [Widgetbook Guide](docs/design_system/widgetbook_guide.md)
- [Widgetbook for Designers](docs/design/widgetbook_for_designers.md)
- [Illustrator Brief](docs/release_notes/v1.0.0_illustrator_brief.md)

### Deployment
- [Fastlane Setup](docs/deployment/fastlane_setup.md)
- [Fastlane Troubleshooting](docs/deployment/fastlane_troubleshooting.md)
- [Screenshot Guidelines](docs/deployment/screenshot_guidelines.md)

