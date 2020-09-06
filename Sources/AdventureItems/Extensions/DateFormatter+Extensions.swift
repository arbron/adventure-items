//
//  DateFormatter+Extensions.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-06.
//

import Foundation

extension DateFormatter {
    static var iso8601date: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
