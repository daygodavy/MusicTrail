//
//  Date+Ext.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/20/23.
//

import Foundation


extension Date {
    
    static let monthYear: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}
