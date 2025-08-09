//
//  ChartTimeRange.swift
//  TonTon
//
//  Time range options for chart displays
//  Used across all chart components
//

import Foundation

enum ChartTimeRange: CaseIterable {
    case week
    case month
    case threeMonths
    case sixMonths
    case year
    
    var displayName: String {
        switch self {
        case .week:
            return "1週間"
        case .month:
            return "1ヶ月"
        case .threeMonths:
            return "3ヶ月"
        case .sixMonths:
            return "6ヶ月"
        case .year:
            return "1年"
        }
    }
    
    var dateRange: (start: Date, end: Date) {
        let now = Date()
        let calendar = Calendar.current
        let endDate = now
        
        let startDate: Date
        switch self {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return (start: startDate, end: endDate)
    }
    
    var axisStride: Calendar.Component {
        switch self {
        case .week:
            return .day
        case .month:
            return .day
        case .threeMonths:
            return .weekOfYear
        case .sixMonths:
            return .weekOfYear
        case .year:
            return .month
        }
    }
    
    var axisFormat: String {
        switch self {
        case .week:
            return "M/d"
        case .month:
            return "M/d"
        case .threeMonths:
            return "M/d"
        case .sixMonths:
            return "M/d"
        case .year:
            return "M月"
        }
    }
    
    var dataPointInterval: Calendar.Component {
        switch self {
        case .week, .month:
            return .day
        case .threeMonths, .sixMonths:
            return .day
        case .year:
            return .weekOfYear
        }
    }
}