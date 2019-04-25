//
//  CustomStringConvertible.swift
//  Wisk_App
//
//  Created by Michael Westbrooks on 5/28/18.
//  Copyright © 2018 redroostertechnologiesinc. All rights reserved.
//

import Foundation

extension CustomStringConvertible {
    public var description : String {
        var description: String = "***** \(type(of: self)) *****\n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }
        return description
    }
    
//    public var toDict: [String: Any] {
//        var dictionary: [String: Any] = [String: Any]()
//        let selfMirror = Mirror(reflecting: self)
//        for child in selfMirror.children {
//            if let propertyName = child.label {
//                if !(child.value is [String: Any]) && child.value is Name || child.value is [Info] || child.value is [Media] || child.value is PaymentMethod || child.value is Settings {
//                    dictionary[propertyName] = (child.value as AnyObject).toDict
//                }
//                dictionary[propertyName] = child.value
//            }
//        }
//        return dictionary
//    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
