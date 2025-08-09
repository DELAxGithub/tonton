
//
//  MealAnalysisResultView.swift
//  TonTon
//
//  Created by Gemini on 2025/08/06.
//

import SwiftUI

struct MealAnalysisResultView: View {
    @Environment(\.dismiss) private var dismiss
    let analysisResult: MealAnalysisResult
    
    // Callback to handle saving the meal
    let onSave: (MealRecord) -> Void

    // State for editable fields
    @State private var mealName: String
    @State private var calories: String
    @State private var protein: String
    @State private var fat: String
    @State private var carbs: String
    @State private var mealTimeType: MealTimeType = .lunch

    init(analysisResult: MealAnalysisResult, onSave: @escaping (MealRecord) -> Void) {
        self.analysisResult = analysisResult
        self.onSave = onSave
        _mealName = State(initialValue: analysisResult.mealName)
        _calories = State(initialValue: String(format: "%.0f", analysisResult.calories))
        _protein = State(initialValue: String(format: "%.1f", analysisResult.protein))
        _fat = State(initialValue: String(format: "%.1f", analysisResult.fat))
        _carbs = State(initialValue: String(format: "%.1f", analysisResult.carbs))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("AI解析結果")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)

                    VStack(spacing: 16) {
                        InfoRow(label: "食事名", value: $mealName)
                        InfoRow(label: "カロリー", value: $calories, unit: "kcal")
                        InfoRow(label: "タンパク質", value: $protein, unit: "g")
                        InfoRow(label: "脂質", value: $fat, unit: "g")
                        InfoRow(label: "炭水化物", value: $carbs, unit: "g")
                        
                        Picker("食事の種類", selection: $mealTimeType) {
                            ForEach(MealTimeType.allCases) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.top)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("解析結果の確認")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveMealRecord()
                    }
                }
            }
        }
    }

    private func saveMealRecord() {
        let mealRecord = MealRecord(
            mealName: mealName,
            calories: Double(calories) ?? 0,
            protein: Double(protein) ?? 0,
            fat: Double(fat) ?? 0,
            carbs: Double(carbs) ?? 0,
            mealTimeType: mealTimeType,
            consumedAt: Date()
        )
        onSave(mealRecord)
        dismiss()
    }
}

struct InfoRow: View {
    let label: String
    @Binding var value: String
    var unit: String? = nil

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            TextField(label, text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
                .keyboardType(label.contains("カロリー") || label.contains("タンパク質") || label.contains("脂質") || label.contains("炭水化物") ? .decimalPad : .default)
            if let unit = unit {
                Text(unit)
            }
        }
    }
}
