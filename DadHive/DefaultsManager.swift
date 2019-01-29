//
//  GumboDefaults.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/18/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

class DefaultsManager {
    init() { }
    
    func setDefault(withData data: Any, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func setDefault(withData data: String, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func setDefault(withData data: Int, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func setDefault(withData data: Bool, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func setDefault(withData data: [String: Any], forKey key: String) {
        UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: data), forKey: key)
    }
    
    func setDefault(withData data: Array<Any>, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }

    func retrieveAnyDefault(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func retrieveStringDefault(forKey key: String) -> String? {
        return UserDefaults.standard.object(forKey: key) as? String ?? nil
    }
    
    func retrieveIntDefault(forKey key: String) -> Int? {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func retrieveBoolDefault(forKey key: String) -> Bool? {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func retrieveDictDefault(forKey key: String) -> [String:Any]? {
        return UserDefaults.standard.dictionary(forKey: key) ?? nil
    }
    
    func retrieveArrayDefault(forKey key: String) -> Array<Any>? {
        return UserDefaults.standard.array(forKey: key) ?? nil
    }
    
    func deleteDefault(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}
