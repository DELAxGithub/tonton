# tonton - UI Components & Design System Reference

> Health tracking iOS app built with Flutter. Calorie "savings" concept (like a piggy bank) with AI-powered meal analysis.

---

## Brand Identity

- **Theme**: Warm pink piggy bank motif
- **Primary Color**: `#FF9AA2` (Pig Pink)
- **Target Platform**: iOS (Apple HIG compliant)
- **Fonts**: Noto Sans JP (Japanese), SF Pro Display (iOS system)
- **Dark Mode**: Fully supported

---

## Design Tokens

### Spacing (4pt grid)

| Token | Value |
|-------|-------|
| xxs | 4pt |
| xs | 8pt |
| sm | 12pt |
| md (default) | 16pt |
| lg | 20pt |
| xl | 24pt |
| xxl | 32pt |
| xxxl | 48pt |

### Corner Radius

| Token | Value |
|-------|-------|
| small | 6pt |
| medium | 10pt |
| large | 13pt |
| extraLarge | 20pt |
| full (circle) | 999pt |

### Elevation (Shadow Levels)

| Level | Offset | Usage |
|-------|--------|-------|
| 0 | 0pt | Flat |
| 1 | 1pt | Subtle |
| 2 | 2pt | Light |
| 3 | 4pt | Medium |
| 4 | 8pt | High |
| Premium | Pink glow | CTA buttons |

### Minimum Tap Target

| Token | Value |
|-------|-------|
| tapTarget | 44pt |
| compactButton | 28pt |
| button | 34pt |
| largeButton | 44pt |

### Animation Durations

| Token | Value |
|-------|-------|
| fast | 150ms |
| normal | 250ms |
| slow | 350ms |
| verySlow | 500ms |

---

## Color System

### Brand

| Name | Hex | Usage |
|------|-----|-------|
| Pig Pink | `#FF9AA2` | Primary / brand color |
| Pig Pink Dark | `#E0576A` | Emphasis / pressed |
| Primary Gradient | Pink linear gradient | Hero sections |

### Nutrition Colors

| Nutrient | Color | Hex |
|----------|-------|-----|
| Protein | Red | `#FF3B30` |
| Fat | Yellow | `#FFCC00` |
| Carbs | Blue | `#007AFF` |

### Semantic Colors

| Name | Color | Hex |
|------|-------|-----|
| Success | Green | `#34C759` |
| Warning | Orange | `#FF9500` |
| Error | Red | `#FF3B30` |
| Info | Blue | `#007AFF` |

### System Colors (Apple HIG)

`systemRed` `systemOrange` `systemYellow` `systemGreen` `systemMint` `systemTeal` `systemCyan` `systemBlue` `systemIndigo` `systemPurple` `systemPink` `systemBrown` + 6 levels of `systemGray`

---

## Typography (Apple HIG)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| largeTitle | 34pt | Regular | Page titles |
| title1 | 28pt | Regular | Section titles |
| title2 | 22pt | Regular | Card titles |
| title3 | 20pt | Regular | Subsection titles |
| headline | 17pt | Semibold | Emphasized body |
| body | 17pt | Regular | Default text |
| callout | 16pt | Regular | Secondary text |
| subheadline | 15pt | Regular | Supporting text |
| footnote | 13pt | Regular | Fine print |
| caption1 | 12pt | Regular | Labels |
| caption2 | 11pt | Regular | Smallest text |

### Semantic Text Styles

`navigationTitle` `tabLabel` `button` `textField` `placeholder` `listTitle` `listSubtitle` `sectionHeader` `cardTitle` `cardSubtitle` `metricValue` `metricLabel`

---

## Custom Icons

Font-based icons (`TontonIcons.ttf`), sourced from SVG:

| Icon | Description |
|------|-------------|
| arrow | Navigation arrow |
| bicycle | Cycling activity |
| camera | Photo capture |
| coin | Currency / savings |
| graph | Chart / analytics |
| pigface | Pig character face |
| piggybank | Piggy bank (savings) |
| present | Gift / reward |
| restaurant | Dining / meals |
| scale | Weight scale |
| workout | Exercise activity |

---

## Atomic Design Components

### Atoms (Base Components)

#### TontonButton
Versatile button with Apple HIG sizing.

| Prop | Type | Description |
|------|------|-------------|
| label | String | Button text |
| style | TontonButtonStyle | `filled` / `gray` / `plain` / `destructive` |
| size | TontonButtonSize | `small` / `regular` / `large` |
| isFullWidth | bool | Stretch to container width |
| isLoading | bool | Show spinner |
| icon | IconData? | Optional leading icon |

**Variants**: `.primary()` `.secondary()` `.text()`

**TontonIconButton**: Icon-only button (44pt touch target)

---

#### TontonTextField
Text input with validation states.

| Prop | Type | Description |
|------|------|-------------|
| style | TontonTextFieldStyle | `bordered` / `plain` / `rounded` |
| placeholder | String? | Hint text |
| errorText | String? | Error message (red) |
| helperText | String? | Helper text below |
| leading / trailing | Widget? | Prefix / suffix widgets |
| obscureText | bool | Password mode |

**TontonSearchField**: Pre-configured search variant with icon + clear button.

---

#### TontonCardBase
Card container with shadow and border.

| Prop | Type | Description |
|------|------|-------------|
| elevation | double | Shadow level (0-4) |
| padding | EdgeInsets? | Inner padding |
| backgroundColor | Color? | Card background |
| borderColor | Color? | Border color |
| onTap | VoidCallback? | Tap handler |

---

#### TontonSectionHeader
Section divider with title.

| Prop | Type | Description |
|------|------|-------------|
| title | String | Section title |
| subtitle | String? | Subtitle text |
| icon | IconData? | Leading icon |
| action | Widget? | Trailing action widget |

---

#### LabeledTextField
Form field with label above.

| Prop | Type | Description |
|------|------|-------------|
| label | String | Field label |
| hintText | String | Placeholder |
| controller | TextEditingController | Text controller |
| validator | Function? | Validation logic |
| keyboardType | TextInputType | Input keyboard type |

---

### Molecules (Composite Components)

#### PfcBarDisplay
Protein / Fat / Carbs progress bars with intake vs target.

| Prop | Type | Description |
|------|------|-------------|
| protein | double | Protein grams |
| fat | double | Fat grams |
| carbs | double | Carbs grams |
| title | String | Section title |

Colors: Protein = Red, Fat = Yellow, Carbs = Blue

---

#### DailyStatRing
Circular progress indicator (80x80 px).

| Prop | Type | Description |
|------|------|-------------|
| icon | IconData | Center icon |
| label | String | Label text |
| currentValue | double | Current value |
| targetValue | double? | Target value |
| progress | double | 0.0 - 1.0 |

---

#### PfcPieChart
Pie chart showing P/F/C ratio (uses fl_chart).

| Prop | Type | Description |
|------|------|-------------|
| protein | double | Protein grams |
| fat | double | Fat grams |
| carbs | double | Carbs grams |

---

#### MetricCard
Single metric display with icon and optional trend badge.

| Prop | Type | Description |
|------|------|-------------|
| title | String | Metric label |
| value | String | Display value |
| icon | IconData | Leading icon |
| subtitle | String? | Supporting text |
| badge | TrendBadge? | Up/down/flat indicator |

---

#### NavigationLinkCard
Tappable card for navigation.

| Prop | Type | Description |
|------|------|-------------|
| icon | IconData | Card icon |
| label | String | Card label |
| onTap | VoidCallback? | Navigation callback |

---

#### Feedback Components

| Component | Variants | Description |
|-----------|----------|-------------|
| **ErrorDisplay** | `.network()` `.auth()` `.data()` `.custom()` | Error state with retry button |
| **LoadingIndicator** | `.fullScreen()` `.card()` | Loading spinner |
| **EmptyState** | `.noMeals()` `.noData()` `.noProgress()` `.noSavings()` `.noSearchResults()` | Empty content placeholder |
| **ConfirmDialog** | `.delete()` `.save()` `.exit()` | Confirmation modal |

---

### Organisms (Section-Level Components)

#### HeroPiggyBankDisplay
Monthly savings goal hero section.

**Shows**: Linear progress bar (color changes by achievement), target/current value, achievement %, remaining days, required avg kcal/day.

---

#### DailySummarySection
Daily calorie savings summary.

**Layout**: Large savings number in center (+/- color-coded), intake card on left, burn card on right.

---

#### CalorieSummaryRow
Three horizontal cards: Intake (green) | Burn (orange) | Savings (pink).

---

#### StatsGrid
Configurable grid of stat items.

| Prop | Type | Description |
|------|------|-------------|
| items | List\<StatItem\> | Stat data (title, value, icon) |
| crossAxisCount | int | Columns (default: 2) |

---

#### PfcBalanceCard
PFC overview: pie chart (left) + detailed values (right).

---

### Templates (Page Layouts)

#### AppShell
Base scaffold with appBar, body, bottomNav, FAB.

#### StandardPageLayout
Scrollable page with consistent 16pt padding.

---

## Screens (22 total)

### Auth Flow
| Screen | Route | Description |
|--------|-------|-------------|
| LoginScreen | `/login` | Email/password login |
| SignupScreen | `/signup` | Account registration |

### Onboarding Flow
| Screen | Route | Description |
|--------|-------|-------------|
| OnboardingScreen | `/onboarding` | Welcome / intro slides |
| BasicInfoScreen | `/onboarding/basic-info` | Nickname, weight, gender*, age* |
| SetStartDateScreen | `/onboarding/start-date` | Goal start date picker |
| WeightInputScreen | `/onboarding/weight` | Initial weight entry |
| HealthKitScreen | `/onboarding/health-kit` | HealthKit permission (disabled) |

*\* Gender and age selection UI: TODO*

### Main App (Bottom Navigation)
| Screen | Route | Description |
|--------|-------|-------------|
| HomeScreen | `/` | Dashboard: calorie savings, PFC remaining, AI advice, today's meals |
| ProfileScreen | `/profile` | Edit nickname, weight goal, current weight |
| SettingsScreen | `/settings` | App settings |

### AI Meal Logging Flow
| Screen | Route | Description |
|--------|-------|-------------|
| Step 1: Camera | `/ai-meal/camera` | Camera capture or gallery pick |
| Step 2: Analyzing | `/ai-meal/analyzing` | AI analysis progress |
| Step 3: Confirm/Edit | `/ai-meal/confirm` | Review & edit nutrition estimate (calories, PFC, meal time) |

### Progress & Savings
| Screen | Route | Description |
|--------|-------|-------------|
| GraphsScreen | `/progress-achievements` > graphs | Chart selection hub |
| ProgressAchievementsScreen | `/progress-achievements` | Calorie savings history & graph |
| DailyMealsDetailScreen | `/daily-meals-detail` | Per-day meal breakdown |
| SavingsTrendScreen | `/savings-trend` | Savings record list |
| UseSavingsScreen | `/use-savings` | Spend saved calories |

### Deprecated / Inactive
| Screen | Note |
|--------|------|
| TontonCoachScreen | Replaced by modal |
| AddMealScreen / EditMealScreen | Replaced by AI flow |

---

## Bottom Navigation Bar

4 tabs:

| Tab | Icon | Screen |
|-----|------|--------|
| Home | home | HomeScreen |
| Progress | graph | ProgressAchievementsScreen |
| Savings | piggybank | SavingsTrendScreen |
| Profile | profile | ProfileScreen |

---

## Key Widgets (Non-Design-System)

| Widget | Description |
|--------|-------------|
| MealRecordCard | Single meal entry with calories, time, PFC |
| AiAdviceCardCompact | Compact AI advice preview on home |
| AiAdviceDisplay | Full AI advice with suggestions |
| AiAdviceModal | Bottom sheet for AI advice |
| NutritionSummaryCard | Calories + PFC overview card |
| NutritionEditor | Editable calorie/PFC fields |
| CalorieWeightChart | Dual-axis line chart (calories + weight) |
| TodaysMealRecordsList | Today's meal entries list |
| MonthlyProgressWidget | Monthly goal progress display |
| TodaySummaryCards | Summary cards for today's metrics |
| DailyHistoryList | Historical daily records list |

---

## Known TODOs (UI)

| Area | What's Missing |
|------|---------------|
| BasicInfoScreen | Gender & age group selection UI |
| ProfileScreen | Gender & age selection, logout button |
| DailyMealsDetailScreen | Meal edit functionality |
| ProgressAchievementsScreen | Weight history chart data |
| assets/images/ | Directory doesn't exist (referenced in pubspec.yaml) |
| Font files | Noto Sans JP .ttf files are 0-byte placeholders |

---

## Tech Stack (for reference)

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.38.9 (Dart 3.10) |
| State Management | Riverpod |
| Routing | GoRouter |
| Local DB | Hive |
| Backend | Supabase (Auth, Edge Functions, Storage) |
| AI | Google Gemini API (direct + Edge Functions) |
| Charts | fl_chart |
| Health Data | iOS HealthKit (health package) |
