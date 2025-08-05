//
//  ContentView.swift
//  TonTon
//
//  Main content view with tab navigation
//  Migrated from Flutter AppShell structure
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @State private var selectedTab = 0
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        Group {
            if let userProfile = currentUserProfile, userProfile.onboardingCompleted {
                // Main app with tab navigation
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("ホーム")
                        }
                        .tag(0)
                    
                    MealLoggingView()
                        .tabItem {
                            Image(systemName: "camera.fill")
                            Text("食事記録")
                        }
                        .tag(1)
                    
                    ProgressView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("進捗")
                        }
                        .tag(2)
                    
                    ChartsContainerView()
                        .tabItem {
                            Image(systemName: "chart.xyaxis.line")
                            Text("グラフ")
                        }
                        .tag(3)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("プロフィール")
                        }
                        .tag(4)
                }
                .accentColor(.primary)
            } else {
                // Onboarding flow
                OnboardingView()
            }
        }
        .onAppear {
            createUserProfileIfNeeded()
        }
    }
    
    private func createUserProfileIfNeeded() {
        if userProfiles.isEmpty {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}