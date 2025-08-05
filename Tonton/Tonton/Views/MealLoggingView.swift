//
//  MealLoggingView.swift
//  TonTon
//
//  Meal logging screen with AI-powered image analysis
//  Migrated from Flutter meal logging flow
//

import SwiftUI
import SwiftData

struct MealLoggingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealRecords: [MealRecord]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Camera section for meal photo
                cameraSection
                
                // Recent meals section
                recentMealsSection
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("食事記録")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private var cameraSection: some View {
        VStack(spacing: 16) {
            Text("食事の写真を撮って、AIが自動でカロリーを計算します")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Open camera for meal photo
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("写真を撮る")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var recentMealsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("最近の食事")
                    .font(.headline)
                Spacer()
                
                Button("すべて見る") {
                    // Navigate to all meals
                }
                .font(.subheadline)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(mealRecords.prefix(5))) { meal in
                    MealRecordRowView(meal: meal)
                }
            }
            
            if mealRecords.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("まだ食事が記録されていません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("写真を撮って最初の食事を記録しましょう")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
            }
        }
    }
}

struct MealRecordRowView: View {
    let meal: MealRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            Image(systemName: mealTypeIcon)
                .font(.title2)
                .foregroundColor(mealTypeColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(meal.mealTimeType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(meal.formattedDate())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(meal.calories)) kcal")
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Text("P:\(Int(meal.protein))")
                    Text("F:\(Int(meal.fat))")
                    Text("C:\(Int(meal.carbs))")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var mealTypeIcon: String {
        switch meal.mealTimeType {
        case .breakfast: return "sun.rise"
        case .lunch: return "sun.max"
        case .dinner: return "moon"
        case .snack: return "cup.and.saucer"
        }
    }
    
    private var mealTypeColor: Color {
        switch meal.mealTimeType {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        case .snack: return .green
        }
    }
}

#Preview {
    MealLoggingView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}