# Widgetbook for Designers - TonTon Component Explorer

## What is Widgetbook?

Widgetbook is your window into the actual components used in the TonTon app. Think of it as a living style guide where you can interact with real UI components, test different states, and see exactly how your designs translate to code.

## Why It Matters

- **See Real Implementation**: View components exactly as they appear in the app
- **Test Edge Cases**: Check how designs handle long text, empty states, errors
- **Ensure Consistency**: Verify that all components follow the design system
- **Faster Iteration**: Test ideas without waiting for full app builds
- **Better Communication**: Use the same component names as developers

## Accessing Widgetbook

### Online (Coming Soon)
```
https://YOUR_ORG.github.io/codex2-master-widgetbook/
```

### Local Access
Ask a developer to run:
```bash
flutter run -t widgetbook/main.dart -d chrome
```

## Interface Overview

![Widgetbook Interface](assets/widgetbook_interface.png) *(Screenshot to be added)*

### 1. Component Tree (Left Panel)
- Hierarchical list of all components
- Organized by atomic design principles
- Search functionality

### 2. Canvas (Center)
- Live component preview
- Responsive to property changes
- Accurate rendering

### 3. Knobs Panel (Right)
- Interactive controls
- Adjust text, numbers, toggles
- Real-time updates

### 4. Addons Bar (Top)
- Device frames
- Theme switcher
- Text scale
- Grid overlay

## Quick Start Tutorial

### Step 1: Find a Component

1. Open Widgetbook in your browser
2. Look at the left panel
3. Navigate through:
   - **Themes** - Colors and typography
   - **Atoms** - Basic components
   - **Molecules** - Combined components
   - **Organisms** - Complex sections

### Step 2: Interact with Components

1. Click on any component (e.g., "TontonButton")
2. Look at the right panel for knobs
3. Try changing:
   - Text content
   - Enable/disable states
   - Size options
   - Color variants

### Step 3: Test Different Scenarios

1. **Device Testing**
   - Click device icon (top bar)
   - Select iPhone 14, iPad, etc.
   - See responsive behavior

2. **Theme Testing**
   - Click theme icon
   - Toggle light/dark mode
   - Check contrast and readability

3. **Accessibility Testing**
   - Click text scale icon
   - Test with 0.8x to 1.5x scale
   - Ensure layouts don't break

## Component Exploration Guide

### 🎨 Design Tokens

#### Color Palette
**Path**: `Themes > Color Palette > Brand Colors`

What to check:
- Brand pink variations
- System color usage
- Semantic colors (success, error)
- Dark mode equivalents

Try this:
1. Switch to dark mode
2. Check if colors maintain sufficient contrast
3. Note any colors that don't work well

#### Typography
**Path**: `Themes > Typography > Display Styles`

What to check:
- All text sizes and weights
- Japanese text rendering
- Line height and spacing
- Semantic styles (button text, captions)

Try this:
1. Switch between English and Japanese
2. Test with maximum text scale (1.5x)
3. Check for text truncation

### 🔘 Interactive Components

#### Buttons
**Path**: `Atoms > TontonButton > All Variants`

States to test:
- Default
- Hover (on desktop)
- Pressed
- Disabled
- Loading

Variations:
- Primary (filled)
- Secondary (outlined)
- Text only
- With icons
- Different sizes

#### Input Fields
**Path**: `Atoms > TontonTextField > TextField States`

Test scenarios:
- Empty state
- Focused state
- Filled state
- Error state
- With helper text
- Password fields

### 📊 Data Visualization

#### PFC Bar Display
**Path**: `Molecules > PFCBarDisplay > Interactive PFC Bar`

What to adjust:
- Protein, Fat, Carbs values
- Show/hide labels
- Show/hide percentages
- Test with extreme values (0, very high)

#### Daily Stats Ring
**Path**: `Molecules > Calorie Displays > Daily Stat Ring`

Test cases:
- Under calorie goal (good)
- Exactly at goal
- Over calorie goal
- Very active day
- No activity

### 🏦 Key Features

#### Hero Piggy Bank
**Path**: `Organisms > HeroPiggyBankDisplay > Different States`

Important states:
- Just started (empty)
- On track (partial)
- Almost there
- Goal achieved
- Month ended scenarios

#### Empty States
**Path**: `Molecules > Feedback > Empty State`

Check for:
- Clear messaging
- Appropriate illustrations
- Actionable CTAs
- Consistent styling

## Common Design Checks

### 1. Spacing Consistency
- Enable grid overlay (top bar)
- Check 4pt/8pt spacing system
- Verify padding matches design

### 2. Color Application
- Switch themes frequently
- Check brand color usage
- Verify semantic color meaning

### 3. Typography Hierarchy
- Check size progression
- Verify weight usage
- Test readability

### 4. Responsive Behavior
- Test on smallest device (iPhone SE)
- Test on largest device (iPad)
- Check line wrapping
- Verify touch targets (44pt minimum)

### 5. State Completeness
- Every interactive element has:
  - Default state
  - Hover/focus state
  - Active/pressed state
  - Disabled state
  - Error state (if applicable)

## Collaboration Workflow

### Reporting Issues

When you find a component issue:

1. **Document the State**
   - Note component path
   - Screenshot with device frame
   - Record knob settings

2. **Describe the Problem**
   ```
   Component: Atoms > TontonButton > Primary
   Issue: Disabled state has insufficient contrast
   Device: iPhone 14
   Theme: Dark mode
   Knobs: Enabled = false
   ```

3. **Suggest Solution**
   - Reference design specs
   - Provide hex codes
   - Show mockup if needed

### Requesting New Components

1. **Check Existing Components**
   - Search Widgetbook first
   - Look for similar patterns
   - Consider composition

2. **Define Requirements**
   - List all states needed
   - Specify responsive behavior
   - Note accessibility needs

3. **Provide Examples**
   - Show in context
   - Include all variations
   - Specify interactions

## Pro Tips

### 1. Keyboard Shortcuts
- `Cmd/Ctrl + K` - Search components
- `Space` - Toggle canvas zoom
- `Esc` - Close panels

### 2. URL Sharing
- Each component state has unique URL
- Share specific configurations
- Bookmark frequently used views

### 3. Batch Testing
- Open multiple browser tabs
- Compare components side-by-side
- Test same component in different themes

### 4. Screenshot Tools
- Use browser DevTools for precise captures
- Include device frame for context
- Annotate with browser extensions

## Troubleshooting

### Component Not Updating
- Refresh the page
- Clear browser cache
- Check console for errors

### Knobs Not Working
- Ensure you've selected a use case
- Some knobs only work with certain states
- Try resetting to defaults

### Performance Issues
- Close other browser tabs
- Disable browser extensions
- Use Chrome for best performance

## Frequently Asked Questions

### Can I edit components directly?
No, Widgetbook is read-only. Request changes through the normal design process.

### Why doesn't component X have feature Y?
Components show actual implementation. If a feature is missing, it may not be built yet.

### How often is Widgetbook updated?
Every time code is pushed to main branch, Widgetbook rebuilds automatically.

### Can I download the components?
You can screenshot them, but the code requires the full Flutter environment.

### Who maintains Widgetbook?
Developers update it when they change components. It's always in sync with the app.

## Resources

- [TonTon Design System](../design_system/README.md)
- [Component Guidelines](../design_system/component_guidelines.md)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Material Design](https://material.io)
- [iOS HIG](https://developer.apple.com/design/)

## Getting Help

- **Technical Issues**: Ask your development team
- **Design Questions**: Refer to design system docs
- **Feature Requests**: Submit through normal channels

Remember: Widgetbook shows what's actually built, not what's planned. It's your source of truth for implementation.