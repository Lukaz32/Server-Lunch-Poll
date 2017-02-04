//
//  File.swift
//  Lunch-Poll
//
//  Created by Lucas Pereira on 04/02/17.
//
//

import Foundation

// MARK: Extensions

extension Date {
    
    static func date(fromJsonDate jsonDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: jsonDate)!
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
}

// MARK: Global func

func +=<U,T>( lhs: inout [U:T], rhs: [U:T]) {
    for (key, value) in rhs {
        lhs[key] = value
    }
}
