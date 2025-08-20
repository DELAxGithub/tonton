//
//  TonTonApp.swift
//  TonTon
//
//  Main app entry point for TonTon SwiftUI
//  カロリー貯金で健康管理を楽しくするアプリ
//

import SwiftUI
import SwiftData

@main
struct TonTonApp: App {
    // Shared service instances
    @StateObject private var aiServiceManager = AIServiceManager()
    @StateObject private var healthKitService = HealthKitService()
    @StateObject private var cloudKitService = CloudKitService()
    
    var body: some Scene {
        WindowGroup {
            AppShell()
                .modelContainer(for: [
                    UserProfile.self,
                    MealRecord.self,
                    WeightRecord.self,
                    CalorieSavingsRecord.self,
                    DailySummary.self
                ])
                .environmentObject(aiServiceManager)
                .environmentObject(healthKitService)
                .environmentObject(cloudKitService)
        }
    }
}