//
//  DateUtil.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/20/23.
//

import Foundation

enum DateUtil {
    
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let releaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static func compareMonthYear(s1: String, s2: String) -> ComparisonResult {
        guard let date1 = monthYearFormatter.date(from: s1),
              let date2 = monthYearFormatter.date(from: s2) else {
            return .orderedSame
        }
        return date1.compare(date2)
    }
}
