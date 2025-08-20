//
//  AppShell.swift
//  TonTon
//
//  Main application shell with tab navigation
//  Complete TonTon functionality app structure
//

import SwiftUI

struct AppShell: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var aiServiceManager: AIServiceManager
    @EnvironmentObject private var healthKitService: HealthKitService
    @EnvironmentObject private var cloudKitService: CloudKitService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)
            
            // Meal Logging Tab
            MealLoggingView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("食事記録")
                }
                .tag(1)
            
            // Progress Tab
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("進捗")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("プロフィール")
                }
                .tag(3)
        }
        .accentColor(.pink)
        .onAppear {
            Task {
                await healthKitService.initialize()
                await cloudKitService.initialize()
            }
        }
    }
}

#Preview {
    AppShell()
        .modelContainer(for: [
            UserProfile.self,
            MealRecord.self,
            WeightRecord.self,
            CalorieSavingsRecord.self,
            DailySummary.self
        ])
}