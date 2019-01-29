//
//  Utils.swift
//  CheftHandedOwner
//
//  Created by Iziah Reid on 7/9/18.
//  Copyright © 2018 NuraCode. All rights reserved.
//

//
//  Utils.swift
//  HomeChatrDemo
//
//  Created by Iziah on 2/9/18.
//  Copyright © 2018 nuracode. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class Utilities {

    public static func savePermanentString( keyName: String, keyValue: String){
        print("setting internally: \(keyName) as \(keyValue)")
        UserDefaults.standard.set(keyValue, forKey: keyName)
    }
    
    public static func getPermanentString( keyName: String ) -> String{
        print("getting \(keyName)")
        var userIDString =  UserDefaults.standard.object(forKey: keyName)
        if userIDString == nil{
            userIDString = ""
        }
        print("\(userIDString!)")
        return userIDString  as! String
    }

    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public static func DeleteIfExists(path: NSURL) -> Bool {
        var deleted = true
        // var error: NSError?
        if (FileManager.default.fileExists(atPath: path.path!)) {
            do{
                try FileManager.default.removeItem(atPath: path.path!)
            }catch{
                deleted = false
            }
        }
        return deleted
    }
    
    public static func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0..<len {
            // generate a random index based on your array of characters count
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            // append the random character to your string
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}

