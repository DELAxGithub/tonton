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
        }
    }
}