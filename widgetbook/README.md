# TonTon Widgetbook

This directory contains the Widgetbook component catalog for the TonTon design system.

## Overview

Widgetbook is an interactive component catalog that allows developers and designers to:
- Browse all UI components in isolation
- Test components with different configurations
- Preview components across different devices and themes
- Document component usage and variations

## Running Widgetbook

### Development Mode

Run Widgetbook with hot reload:

```bash
flutter run -t widgetbook/main.dart -d chrome
```

Or on a specific device:

```bash
# iOS Simulator
flutter run -t widgetbook/main.dart -d iPhone

# Android Emulator
flutter run -t widgetbook/main.dart -d emulator-5554

# macOS (if configured)
flutter run -t widgetbook/main.dart -d macos
```

### Build for Web

Build Widgetbook for web deployment:

```bash
flutter build web -t widgetbook/main.dart --base-href /widgetbook/
```

## Project Structure

```
widgetbook/
├── main.dart                    # Widgetbook app entry point
├── use_cases/                   # Component stories
│   ├── atoms/                   # Basic components
│   │   ├── tonton_button_use_cases.dart
│   │   ├── tonton_card_use_cases.dart
│   │   └── tonton_text_field_use_cases.dart
│   ├── molecules/               # Compound components
│   │   ├── pfc_bar_display_use_cases.dart
│   │   └── calorie_display_use_cases.dart
│   ├── organisms/               # Complex components
│   │   ├── hero_piggy_bank_use_cases.dart
│   │   └── daily_summary_section_use_cases.dart
│   └── themes/                  # Theme showcases
│       ├── color_showcase.dart
│       └── typography_showcase.dart
└── README.md                    # This file
```

## Adding New Components

### 1. Create a Use Case File

Create a new file in the appropriate category:

```dart
// widgetbook/use_cases/atoms/my_component_use_cases.dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/atoms/my_component.dart';

final myComponentUseCases = WidgetbookComponent(
  name: 'MyComponent',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return MyComponent();
      },
    ),
  ],
);
```

### 2. Add Interactive Knobs

Make your component interactive:

```dart
WidgetbookUseCase(
  name: 'Interactive',
  builder: (context) {
    final text = context.knobs.string(
      label: 'Text',
      initialValue: 'Hello',
    );
    final isEnabled = context.knobs.boolean(
      label: 'Enabled',
      initialValue: true,
    );
    
    return MyComponent(
      text: text,
      enabled: isEnabled,
    );
  },
),
```

### 3. Register in Main File

Add your use case to `widgetbook/main.dart`:

```dart
import 'use_cases/atoms/my_component_use_cases.dart';

// In the directories array:
WidgetbookFolder(
  name: 'Atoms',
  children: [
    // ... existing components
    myComponentUseCases,
  ],
),
```

## Available Addons

Widgetbook is configured with the following addons:

### Device Frame
- Preview components on different iOS devices
- Test responsive layouts
- Available devices: iPhone SE, iPhone 12/13/14, iPad Pro

### Theme Switcher
- Toggle between light and dark themes
- Ensure components work in both modes

### Text Scale
- Test components with different text scales (0.8x - 1.5x)
- Ensure accessibility compliance

### Localization
- Switch between English and Japanese
- Test text overflow and layout issues

### Inspector
- View widget properties
- Debug layout issues

### Grid
- Overlay alignment grid
- Ensure consistent spacing

## Best Practices

### 1. Component Organization

- **Atoms**: Basic building blocks (buttons, inputs, cards)
- **Molecules**: Combinations of atoms (form fields, stat displays)
- **Organisms**: Complex UI sections (headers, forms, summaries)
- **Templates**: Page layouts (not currently used)

### 2. Use Case Naming

- Use descriptive names for use cases
- Group related variations together
- Include edge cases and error states

### 3. Knobs Guidelines

- Provide sensible defaults
- Use appropriate knob types:
  - `string`: Text inputs
  - `boolean`: Toggles
  - `double.slider`: Numeric ranges
  - `list`: Dropdown selections

### 4. Documentation

- Add comments explaining component purpose
- Document required vs optional props
- Include usage examples in complex cases

## Deployment

### GitHub Pages

1. Build Widgetbook:
   ```bash
   flutter build web -t widgetbook/main.dart --base-href /tonton-widgetbook/
   ```

2. Deploy to GitHub Pages:
   ```bash
   cd build/web
   git init
   git add -A
   git commit -m "Deploy Widgetbook"
   git push -f https://github.com/YOUR_ORG/tonton-widgetbook.git master:gh-pages
   ```

### CI/CD Integration

See `.github/workflows/widgetbook.yml` for automated deployment setup.

## Troubleshooting

### Component Not Showing

1. Ensure the use case is imported in `main.dart`
2. Check for syntax errors in the use case file
3. Verify the component is exported from the design system

### Hot Reload Issues

1. Stop and restart the Flutter app
2. Run `flutter clean` if issues persist
3. Check for circular dependencies

### Build Failures

1. Ensure all dependencies are installed: `flutter pub get`
2. Check for version conflicts in `pubspec.yaml`
3. Run `flutter doctor` to verify setup

## Contributing

When adding new components:

1. Create the component in the design system first
2. Add comprehensive use cases in Widgetbook
3. Test all variations and edge cases
4. Update this README if adding new categories

## Resources

- [Widgetbook Documentation](https://docs.widgetbook.io)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Material Design Guidelines](https://material.io/design)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)