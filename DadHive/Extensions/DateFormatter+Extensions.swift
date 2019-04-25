//
//  DateFormatter+Extensions.swift
//  test
//
//  Created by Michael Westbrooks on 11/14/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    @objc public class func isSystemFormat24Hours() -> Bool {
        let formatter = Foundation.DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let formattedCurrentTime = formatter.string(from: Date())
        return formattedCurrentTime.range(of: formatter.amSymbol) == nil && formattedCurrentTime.range(of: formatter.pmSymbol) == nil
    }
    
//    public class func getFormattedDate(_ date: String) -> String {
//        return self.stringWithFormatEEEMMMddy(forTimestamp: date)
//    }
//    
//    public class func getFormattedTime(_ date: String) -> String {
//        return self.DateFormatter.stringWithLocalizedTimeFormat(forTimestamp: date)
//    }
//    
    public class func stringWithFormatMMMDDCOMMAYYYY(_ date: String, timeZone: TimeZone) -> String {
        if let date = dateWithFormatMMMDDCOMMAYYYY(date, timeZone: timeZone) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateFormatter.timeZone = timeZone
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    public class func detectAndFormat(_ date: String, timeZone: TimeZone) -> Date? {
        let possibleFormats = [
            "yyyy-MM-dd'T'HH:mm:ssZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        return possibleFormats.compactMap { (format) -> Date? in
            return dateWithFormat(date, format: format, timeZone: timeZone)
            }.first
    }
    
    public class func dateWithFormat(_ date: String, format: String, timeZone: TimeZone) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: date)
        return date
    }
    
    public class func dateWithFormatMMMDDCOMMAYYYY(_ date: String, timeZone: TimeZone) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: date)
        return date
    }
    
}
