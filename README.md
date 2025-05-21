# TonTon

A health tracking application with iOS HealthKit integration.

## Technology Stack

- **Frontend:** Flutter, Riverpod (state management)
- **Backend:** Supabase (Edge Functions)
- **AI Integration:** OpenAI API (GPT-4o model)
- **Local Storage:** Hive, SharedPreferences
- **Health Integration:** iOS HealthKit

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.\nSee [docs/ICON_FONT.md](docs/ICON_FONT.md) for instructions on generating the custom icon font.

### UI Catalog (Dashbook)

```bash
flutter run -d chrome lib/dashbook.dart
```

ブラウザが自動起動し、Theme / Icons / Atoms を確認できます。

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

