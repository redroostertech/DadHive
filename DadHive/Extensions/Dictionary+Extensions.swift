//
//  Dictionary+Extensions.swift
//  test
//
//  Created by Michael Westbrooks on 11/14/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

public extension Dictionary {
    /**
     Build string representation of HTTP parameter dictionary of keys and objects.
     This percent escapes in compliance with RFC 3986.
     http://www.ietf.org/rfc/rfc3986.txt
     
     - Returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
     */
    
//    func stringFromHttpParameters() -> String {
//        let parameterArray = self.map { (key, value) -> String in
//            let percentEscapedKey = ((key as? String) ?? "").stringByAddingPercentEncodingForURLQueryValue()!
//            let percentEscapedValue = ((value as? String) ?? "").stringByAddingPercentEncodingForURLQueryValue()!
//            return "\(percentEscapedKey)=\(percentEscapedValue)"
//        }
//
//        return parameterArray.joined(separator: "&")
//    }
    
    public func toJsonString() -> String? {
        return toString(object: self)
    }
}

extension NSDictionary {
    public func toJsonString() -> String? {
        return toString(object: self)
    }
}

private func toString(object: Any) -> String? {
    guard JSONSerialization.isValidJSONObject(object), let data = try? JSONSerialization.data(withJSONObject: object) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}
