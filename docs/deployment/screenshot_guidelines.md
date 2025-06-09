# Screenshot Guidelines for TonTon

This guide explains how to create and maintain automated screenshots for the TonTon app.

## Overview

Automated screenshots are generated using Fastlane Snapshot, which runs UI tests to capture app screens in multiple languages and device sizes. This ensures consistent, up-to-date screenshots for App Store submissions and documentation.

## Prerequisites

- Xcode with UI Testing framework
- Fastlane installed (`bundle install` in `ios/` directory)
- Simulators for target devices installed
- Test data configured in the app

## Running Screenshots

### Quick Start

Generate screenshots for all configured devices and languages:

```bash
cd ios
bundle exec fastlane screenshots
```

### Specific Language

To test a specific language:

```bash
cd ios
bundle exec fastlane snapshot --languages "ja"
```

### Specific Device

To test on a specific device:

```bash
cd ios
bundle exec fastlane snapshot --devices "iPhone 14 Pro"
```

## Configuration

### Supported Devices

Configured in `ios/fastlane/Snapfile`:
- iPhone 8 (4.7" - smallest supported)
- iPhone 14 (6.1" - standard)
- iPhone 14 Pro (6.1" - with Dynamic Island)
- iPhone 14 Pro Max (6.7" - largest)
- iPad Pro 12.9" (tablet)

### Supported Languages

- Japanese (`ja`) - Primary market
- English (`en-US`) - International

### Screenshot Scenarios

Defined in `ios/RunnerUITests/TonTonUITests.swift`:

1. **Home Screen** (`01_home_screen`)
   - Shows daily calorie summary
   - Piggy bank savings display
   - Quick action buttons

2. **Meal Records** (`02_meal_records`)
   - Today's logged meals
   - Calorie and nutrition info
   - Add meal button

3. **AI Meal Analysis** (`03_ai_meal_analysis`)
   - Photo analysis results
   - Detected food items
   - Nutrition breakdown
   - Edit capabilities

4. **Monthly Progress** (`04_monthly_progress`)
   - Calorie savings trend
   - Goal achievement status
   - Historical data

5. **Empty States** (`05_empty_state`)
   - No data scenarios
   - Onboarding prompts
   - Call-to-action buttons

6. **Profile/Settings** (`06_profile_settings`)
   - User information
   - App preferences
   - Account management

## Adding Accessibility IDs

To make UI elements accessible for screenshots, add semantic labels in Flutter:

```dart
// In your Flutter widget
Semantics(
  identifier: 'home_greeting', // Used in UI tests
  child: Text('おはよう, $userName'),
)

// For buttons
ElevatedButton(
  onPressed: () {},
  child: Text('Add Meal'),
  key: Key('add_meal_button'), // Alternative approach
)

// For lists/tables
ListView(
  key: Key('meal_records_table'),
  children: [...],
)
```

## Test Data Setup

### Demo Accounts

Create consistent test data for screenshots:

```swift
// In TonTonUITests.swift
app.launchArguments.append("--ResetData")
app.launchArguments.append("--LoadDemoData")
```

### Mock Data Structure

```json
{
  "user": {
    "name": "田中さん",
    "savedCalories": 12500,
    "monthlyGoal": 15000
  },
  "meals": [
    {
      "name": "朝食",
      "calories": 450,
      "time": "08:30"
    },
    {
      "name": "昼食",
      "calories": 680,
      "time": "12:15"
    }
  ]
}
```

## Maintenance

### When to Update Screenshots

- Before each App Store release
- After major UI changes
- When adding new features
- For marketing materials

### Checklist Before Running

1. **Clean State**
   ```bash
   cd ios
   bundle exec fastlane clear_derived_data
   ```

2. **Update Test Data**
   - Ensure demo data is current
   - Check dates aren't hardcoded
   - Verify progress calculations

3. **Review UI Changes**
   - Check accessibility IDs still match
   - Verify navigation flow
   - Test gesture recognizers

### Common Issues

#### Screenshots Not Capturing

**Problem**: UI test can't find elements

**Solution**:
1. Add accessibility identifiers
2. Increase wait timeouts
3. Check element hierarchy in Xcode

#### Inconsistent Results

**Problem**: Screenshots vary between runs

**Solution**:
1. Disable animations: `--DisableAnimations`
2. Use fixed timestamps
3. Reset data between tests

#### Language Not Switching

**Problem**: App stays in default language

**Solution**:
1. Check `AppleLanguages` launch argument
2. Verify localization files exist
3. Clean and rebuild

## Integration with Release Process

### Manual Release

```bash
# Generate screenshots and deploy
cd ios
bundle exec fastlane create_app_store_screenshots
```

### Automated Release

```bash
# Screenshots + TestFlight
cd ios
bundle exec fastlane beta_with_screenshots
```

### CI/CD Pipeline

Add to GitHub Actions:

```yaml
- name: Generate Screenshots
  run: |
    cd ios
    bundle exec fastlane screenshots
  
- name: Upload Screenshots
  uses: actions/upload-artifact@v3
  with:
    name: screenshots
    path: ios/fastlane/screenshots/
```

## Output Structure

Screenshots are organized by language and device:

```
ios/fastlane/screenshots/
├── en-US/
│   ├── iPhone 8/
│   │   ├── 01_home_screen.png
│   │   ├── 02_meal_records.png
│   │   └── ...
│   ├── iPhone 14 Pro/
│   └── ...
├── ja/
│   ├── iPhone 8/
│   └── ...
├── overlayed/          # Screenshots with marketing text
│   ├── en-US/
│   └── ja/
├── framed/            # Device frames + overlays
│   ├── en-US/
│   └── ja/
└── screenshots.html (preview)
```

## Viewing Results

After generation, open the HTML preview:

```bash
open ios/fastlane/screenshots/screenshots.html
```

This shows all screenshots organized by:
- Language
- Device
- Screen name

## Best Practices

### Consistency

1. **Timing**: Run at consistent times (e.g., morning for breakfast data)
2. **Data**: Use realistic but controlled test data
3. **State**: Always start from clean app state

### Quality

1. **Wait for Loading**: Ensure all content is loaded
2. **Scroll Position**: Capture most important content
3. **Focus State**: Remove keyboards/popovers

### Localization

1. **Text Length**: Test with longer text in each language
2. **Date Formats**: Use locale-appropriate formats
3. **Currency/Units**: Display correct for each market

## Extending Screenshots

### Adding New Screens

1. Add test method in `TonTonUITests.swift`:
   ```swift
   func captureNewFeature() {
       // Navigate to feature
       // Wait for load
       snapshot("07_new_feature")
   }
   ```

2. Call from main test:
   ```swift
   func testCaptureScreenshots() {
       // ... existing screenshots
       captureNewFeature()
   }
   ```

### Adding New Languages

1. Update `Snapfile`:
   ```ruby
   languages([
     "ja",
     "en-US",
     "zh-Hans" # New: Simplified Chinese
   ])
   ```

2. Ensure localizations exist in app

### Adding New Devices

1. Update `Snapfile`:
   ```ruby
   devices([
     # ... existing devices
     "iPad Air (5th generation)" # New
   ])
   ```

2. Install simulator if needed

## Marketing Text Overlays

TonTon uses custom text overlays to enhance screenshots with marketing messages:

### Configuration

Edit `ios/fastlane/screenshot_overlays.json` to customize:

```json
{
  "ja": [
    {
      "filter": "01_home_screen",
      "badge": {
        "text": { "ja": "人気No.1" },
        "background": "#FF3B30",
        "color": "#FFFFFF"
      },
      "cta": {
        "text": { "ja": "今すぐ始める" },
        "background": "#F7B6B9"
      }
    }
  ]
}
```

### Elements

- **Badge**: Eye-catching label (e.g., "New", "Popular")
- **CTA**: Call-to-action button
- **Watermark**: Version/branding info

### Process

1. Raw screenshots captured
2. Marketing overlays added
3. Device frames applied
4. Final images ready for App Store

### Customization

To modify overlay styles:

1. Edit `ios/fastlane/actions/add_text_overlay.rb`
2. Adjust positioning, colors, fonts
3. Test with single screenshot first

## Resources

- [Fastlane Snapshot Documentation](https://docs.fastlane.tools/actions/snapshot/)
- [Fastlane Frameit Documentation](https://docs.fastlane.tools/actions/frameit/)
- [Apple UI Testing Guide](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [Accessibility in Flutter](https://flutter.dev/docs/development/accessibility-and-localization/accessibility)