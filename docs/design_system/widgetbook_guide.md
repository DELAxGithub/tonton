# Widgetbook Guide for TonTon

## What is Widgetbook?

Widgetbook is a component catalog tool for Flutter that allows you to:
- View all UI components in isolation
- Test components with different properties
- Document component usage
- Share design system with team members

## Quick Start

### Running Locally

```bash
# Run in Chrome (recommended for development)
flutter run -t widgetbook/main.dart -d chrome

# Run on iOS Simulator
flutter run -t widgetbook/main.dart -d iPhone

# Run on Android Emulator
flutter run -t widgetbook/main.dart
```

### Accessing Deployed Version

Once deployed, access Widgetbook at:
```
https://YOUR_ORG.github.io/codex2-master-widgetbook/
```

## Navigation

### Component Hierarchy

```
Design System/
├── Themes/
│   ├── Color Palette     # All colors used in the app
│   └── Typography        # Text styles and fonts
├── Atoms/
│   ├── TontonButton      # Button variations
│   ├── TontonCardBase    # Card components
│   └── TontonTextField   # Input fields
├── Molecules/
│   ├── PFCBarDisplay     # Nutrition bar charts
│   └── Calorie Displays  # Calorie metrics
└── Organisms/
    ├── HeroPiggyBank     # Main savings display
    └── DailySummary      # Daily stats section
```

### Using the Interface

1. **Component Tree** (Left Panel)
   - Browse components by category
   - Click to view component variations

2. **Canvas** (Center)
   - Interactive component preview
   - Responsive to knob changes

3. **Knobs Panel** (Right)
   - Modify component properties
   - Test different states

4. **Addons Bar** (Top)
   - Device frames
   - Theme switcher
   - Text scale
   - Grid overlay

## Key Features

### 1. Device Preview

Test components on different devices:
- iPhone SE (smallest)
- iPhone 13 (standard)
- iPhone 14 Plus (large)
- iPad Pro (tablet)

### 2. Theme Testing

Toggle between:
- Light mode
- Dark mode

Ensure all components work in both themes.

### 3. Interactive Knobs

Each component has knobs to control:
- Text content
- Enabled/disabled states
- Numeric values
- Boolean flags
- Color selections

### 4. Accessibility Testing

Use the text scale addon to test:
- Small text (0.8x)
- Default (1.0x)
- Large text (1.5x)

## For Designers

### Reviewing Components

1. **Browse the Catalog**
   - Start with Themes to understand the design system
   - Review Atoms for basic building blocks
   - Check Molecules and Organisms for composed components

2. **Test Variations**
   - Use knobs to see all component states
   - Check edge cases (long text, empty states)
   - Verify dark mode appearance

3. **Document Issues**
   - Take screenshots of problematic states
   - Note which device/theme combination
   - Share specific knob configurations

### Design Tokens

View all design tokens in the Themes section:
- **Colors**: Brand colors, system colors, semantic colors
- **Typography**: All text styles with sizes and weights
- **Spacing**: Standard spacing values (coming soon)
- **Shadows**: Elevation levels (coming soon)

## For Developers

### Adding New Components

1. **Create Component Use Case**
   ```dart
   // widgetbook/use_cases/atoms/new_component_use_cases.dart
   final newComponentUseCases = WidgetbookComponent(
     name: 'NewComponent',
     useCases: [
       WidgetbookUseCase(
         name: 'Default',
         builder: (context) => NewComponent(),
       ),
     ],
   );
   ```

2. **Add Interactive Properties**
   ```dart
   builder: (context) {
     final label = context.knobs.string(
       label: 'Label',
       initialValue: 'Click me',
     );
     return NewComponent(label: label);
   }
   ```

3. **Register in Main**
   - Import the use case file
   - Add to appropriate category

### Best Practices

1. **Comprehensive Coverage**
   - Include all component variations
   - Add edge cases
   - Show error states

2. **Meaningful Knobs**
   - Use descriptive labels
   - Provide realistic defaults
   - Group related properties

3. **Documentation**
   - Add comments for complex components
   - Explain non-obvious behaviors
   - Link to design specifications

## Common Use Cases

### Finding a Component

1. Use the search in the component tree
2. Browse by atomic design category
3. Check similar components in the same folder

### Testing Responsive Design

1. Select different devices from the device frame addon
2. Rotate devices to test landscape
3. Use browser dev tools for custom sizes

### Checking Theme Compliance

1. Toggle between light and dark themes
2. Ensure sufficient contrast
3. Verify brand colors are used correctly

### Validating Accessibility

1. Increase text scale to 1.5x
2. Check that layouts don't break
3. Ensure touch targets remain adequate

## Troubleshooting

### Component Not Updating

- Hot reload should work automatically
- If not, hot restart with 'R' in terminal
- For structural changes, restart the app

### Knobs Not Working

- Ensure knob is connected to component property
- Check for typos in property names
- Verify component rebuilds on property change

### Performance Issues

- Close unused browser tabs
- Disable inspector addon if not needed
- Use production build for smoother experience

## Integration with Development

### VS Code Launch Configuration

Add to `.vscode/launch.json`:
```json
{
  "name": "Widgetbook",
  "request": "launch",
  "type": "dart",
  "program": "widgetbook/main.dart",
  "args": ["-d", "chrome"]
}
```

### Git Workflow

1. Update component in `lib/design_system/`
2. Update/add use cases in `widgetbook/use_cases/`
3. Test all variations
4. Commit both changes together

### CI/CD

- Widgetbook builds on every push to main
- Preview deployments for pull requests
- Automated visual regression testing (planned)

## Future Enhancements

- [ ] Storybook-style documentation
- [ ] Visual regression testing
- [ ] Component usage analytics
- [ ] Design token synchronization
- [ ] Figma plugin integration

## Resources

- [Widgetbook Documentation](https://docs.widgetbook.io)
- [TonTon Design System](../design_system/README.md)
- [Component Guidelines](../design_system/component_guidelines.md)