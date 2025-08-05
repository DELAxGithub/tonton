# TonTon SwiftUI API Reference

## 📱 SwiftUI Views & Components Reference

### 🏗️ Core SwiftUI Architecture

The TonTon SwiftUI app follows modern iOS development patterns with SwiftData and CloudKit integration.

## 🔧 SwiftData Models Reference

### Core Models (`Tonton/Tonton/Models/`)

#### UserProfile - `UserProfile.swift`
```swift
@Model
class UserProfile {
    var displayName: String?
    var weight: Double = 0.0
    var targetWeight: Double?
    var onboardingCompleted: Bool = false
    
    init(displayName: String? = nil, weight: Double = 0.0, targetWeight: Double? = nil, onboardingCompleted: Bool = false)
}
```
- **CloudKit Sync**: Enabled for cross-device profile synchronization
- **Features**: User identification, weight tracking, onboarding state

#### MealRecord - `MealRecord.swift`
```swift
@Model
class MealRecord {
    var mealName: String
    var calories: Double
    var date: Date
    
    init(mealName: String, calories: Double, date: Date = Date())
}
```
- **Purpose**: Store AI-analyzed meal data
- **Features**: Meal identification, caloric content, timestamp tracking

#### WeightRecord - `WeightRecord.swift`
```swift
@Model
class WeightRecord {
    var weight: Double
    var date: Date
    
    init(weight: Double, date: Date = Date())
}
```
- **HealthKit Integration**: Bidirectional sync with Apple Health
- **Features**: Weight tracking, historical data, date correlation

#### CalorieSavingsRecord - `CalorieSavingsRecord.swift`
```swift
@Model
class CalorieSavingsRecord {
    var savedCalories: Double
    var date: Date
    
    init(savedCalories: Double, date: Date = Date())
    
    var formattedSavings: String {
        return savedCalories >= 0 ? "+\(Int(savedCalories)) kcal" : "\(Int(savedCalories)) kcal"
    }
}
```
- **Core Feature**: Calorie savings calculation and display
- **Features**: Daily savings tracking, formatted display strings

#### DailySummary - `DailySummary.swift`
```swift
@Model
class DailySummary {
    var date: Date
    var totalCalories: Double
    
    init(date: Date = Date(), totalCalories: Double = 0.0)
}
```

## 🎯 SwiftUI Views Reference

### Main Views (`Tonton/Tonton/Views/`)

#### HomeView - `HomeView.swift`
```swift
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var savingsRecords: [CalorieSavingsRecord]
    
    var body: some View { /* Main dashboard UI */ }
}
```
- **Purpose**: Main dashboard with daily statistics
- **Features**: Calorie savings display, meal summary, quick actions

#### MealLoggingView - `MealLoggingView.swift`
```swift
struct MealLoggingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    
    var body: some View { /* AI meal logging interface */ }
}
```
- **Purpose**: AI-powered meal logging with camera integration
- **Features**: Camera capture, AI analysis, meal record creation

#### ProfileView - `ProfileView.swift`
```swift
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    var body: some View { /* User profile management */ }
}
```
- **Purpose**: User profile management and settings
- **Features**: Profile editing, weight tracking, app preferences

#### ProgressView - `ProgressView.swift`
```swift
struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savingsRecords: [CalorieSavingsRecord]
    @Query private var weightRecords: [WeightRecord]
    
    var body: some View { /* Progress tracking and analytics */ }
}
```
- **Purpose**: Progress visualization and analytics
- **Features**: Charts, trends, historical data analysis

### Chart Components (`Tonton/Tonton/Views/Charts/`)

#### CalorieSavingsChart - `CalorieSavingsChart.swift`
```swift
struct CalorieSavingsChart: View {
    let savingsData: [CalorieSavingsRecord]
    
    var body: some View {
        Chart {
            ForEach(savingsData, id: \.date) { record in
                LineMark(
                    x: .value("Date", record.date),
                    y: .value("Savings", record.savedCalories)
                )
            }
        }
    }
}
```
- **Framework**: SwiftUI Charts
- **Purpose**: Visual representation of calorie savings over time

#### WeightProgressChart - `WeightProgressChart.swift`
```swift
struct WeightProgressChart: View {
    let weightData: [WeightRecord]
    
    var body: some View { /* Weight progress visualization */ }
}
```

#### NutritionBreakdownChart - `NutritionBreakdownChart.swift`
```swift
struct NutritionBreakdownChart: View {
    let mealData: [MealRecord]
    
    var body: some View { /* Nutrition analysis charts */ }
}
```

## 🔧 Services API Reference

### Core Services (`Tonton/Tonton/Services/`)

#### HealthKitService - `HealthKitService.swift`
```swift
class HealthKitService: ObservableObject {
    // HealthKit authorization and data operations
    func requestAuthorization() async -> Bool
    func readWeightData() async -> [WeightRecord]
    func writeWeightData(_ weight: Double, date: Date) async -> Bool
    
    // Activity and health metrics
    func readActivityData() async -> [ActivityData]
    func getBasalMetabolicRate() async -> Double?
}
```

#### CloudKitService - `CloudKitService.swift`
```swift
class CloudKitService: ObservableObject {
    // CloudKit data synchronization
    func syncUserProfile(_ profile: UserProfile) async -> Bool
    func syncMealRecords() async -> Bool
    func syncWeightRecords() async -> Bool
    
    // CloudKit configuration
    func setupCloudKitContainer() async -> Bool
    func handleCloudKitAccountStatus() async -> CKAccountStatus
}
```

#### AIServiceManager - `AIServiceManager.swift`
```swift
class AIServiceManager: ObservableObject {
    // AI meal analysis
    func analyzeMealImage(_ image: UIImage) async -> MealAnalysisResult
    func generateMealRecommendations(for profile: UserProfile) async -> [MealRecommendation]
    
    // AI service coordination
    func selectBestAIService() -> AIProvider
    func handleAIServiceFailure(_ error: AIError) async -> Bool
}
```

#### DataService - `DataService.swift`
```swift
class DataService: ObservableObject {
    // Core data operations
    func saveMealRecord(_ record: MealRecord) async -> Bool
    func saveWeightRecord(_ record: WeightRecord) async -> Bool
    func calculateDailySavings(for date: Date) async -> Double
    
    // Data aggregation
    func getDailySummary(for date: Date) async -> DailySummary?
    func getWeeklyProgress() async -> [CalorieSavingsRecord]
}
```

## 🎨 SwiftUI Design Patterns

### State Management Patterns
```swift
// SwiftData queries
@Query private var userProfiles: [UserProfile]
@Query(sort: \MealRecord.date, order: .reverse) private var recentMeals: [MealRecord]

// Environment injection
@Environment(\.modelContext) private var modelContext

// Observable objects for services
@StateObject private var healthService = HealthKitService()
@StateObject private var aiService = AIServiceManager()
```

### CloudKit Integration Patterns
```swift
// SwiftData with CloudKit sync
.modelContainer(for: [
    UserProfile.self,
    MealRecord.self,
    WeightRecord.self,
    CalorieSavingsRecord.self,
    DailySummary.self
])
```

### Navigation Patterns
```swift
// SwiftUI NavigationStack
NavigationStack {
    HomeView()
        .navigationDestination(for: ViewType.self) { viewType in
            switch viewType {
            case .mealLogging:
                MealLoggingView()
            case .progress:
                ProgressView()
            case .profile:
                ProfileView()
            }
        }
}
```

## 🔄 Data Flow Architecture

### SwiftData + CloudKit Flow
1. **Local Operations**: SwiftData handles local persistence
2. **Cloud Sync**: CloudKit automatically syncs data across devices
3. **Conflict Resolution**: CloudKit handles merge conflicts automatically
4. **Offline Support**: SwiftData provides offline-first architecture

### HealthKit Integration Flow
1. **Authorization**: Request HealthKit permissions on first launch
2. **Data Reading**: Fetch weight and activity data from HealthKit
3. **Data Writing**: Save app-generated health data to HealthKit
4. **Background Updates**: Handle HealthKit background updates

### AI Service Flow
1. **Image Capture**: Camera integration with AVFoundation
2. **AI Processing**: Native Swift AI services for meal analysis
3. **Result Processing**: Convert AI results to MealRecord objects
4. **Data Persistence**: Save analyzed meal data to SwiftData

---

**Last Updated**: January 2025  
**Platform**: iOS (SwiftUI + SwiftData + CloudKit)  
**For Implementation Details**: See individual Swift files in Xcode project