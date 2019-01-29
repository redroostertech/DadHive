//
//  FIRRealtimeDB.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 9/17/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import Firebase
import ObjectMapper

class FIRRealtimeDB {
    static let shared = FIRRealtimeDB()
    private var dbRef: DatabaseReference!
    private init() {
        Database.database().isPersistenceEnabled = false
        self.dbRef = Database.database().reference()
//        self.dbRef.child("conversations").childByAutoId().setValue([
//            "id": "wuhoag347eoa8gsriubrg978",
//            "sender": [
//                "email": "mwestbrooksjr@gmail.com",
//                "name": [
//                    "fullName": "Michael Westbrooks II"
//                ]
//            ],
//            "recipient": [
//                "email": "test1@gmail.com",
//                "name": [
//                    "fullName": "test user 1"
//                ]
//            ],
//            "lastMessage": [
//                "sender": [
//                    "email": "mwestbrooksjr@gmail.com",
//                    "name": [
//                        "fullName": "Michael Westbrooks II"
//                    ]
//                ],
//                "message": "Sample Message.",
//                "createdAt": "2018-12-29T22:28:12+0000"
//            ]
//        ])
    }
    func retrieveDataOnce(atChild child: String,
                          completion: @escaping (Bool, DataSnapshot?, Error?) -> Void) {
        self.dbRef
            .child(child)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                print("Snapshot exists", snapshot.exists())
                print("Snapshot hasChildren", snapshot.hasChildren())
                print("Snapshot has key", snapshot.key)
                
                if snapshot.childrenCount > 0 {
                    completion(true, snapshot, nil)
                } else {
                    completion(false, nil, Errors.EmptyAPIResponse)
                }
        }
    }
    func retrieveDataOnce(atChild child: String,
                          whereKey key: String,
                          isEqualTo value: Any,
                          completion: @escaping (Bool, DataSnapshot?, Error?) -> Void) {

        self.dbRef.child(child)
            .queryOrdered(byChild: key)
            .queryEqual(toValue: value)
            .observeSingleEvent(of: .value,
                                with: { (snapshot) in

                                    print("Snapshot exists", snapshot.exists())
                                    print("Snapshot hasChildren", snapshot.hasChildren())
                                    print("Snapshot has key", snapshot.key)
                                    
                                    if snapshot.childrenCount > 0 {
                                        completion(true, snapshot, nil)
                                    } else {
                                        completion(false, nil, Errors.EmptyAPIResponse)
                                    }
                                    
        }){
            (error) in
            print("Failed to get snapshot", error.localizedDescription)
            completion(false, nil, error)
        }
    }

    func retrieveDataOnce(atChild child: String,
                          whereKey key: String,
                          isNotEqualTo value: Any,
                          completion: @escaping (Bool, DataSnapshot?, Error?) -> Void) {

        self.dbRef.child(child)
            .queryOrdered(byChild: key)
            .queryEqual(toValue: value)
            .observeSingleEvent(of: .value,
                                with: { (snapshot) in

                                    print("Snapshot exists", snapshot.exists())
                                    print("Snapshot hasChildren", snapshot.hasChildren())
                                    print("Snapshot has key", snapshot.key)

                                    if snapshot.childrenCount > 0 {
                                        completion(true, snapshot, nil)
                                    } else {
                                        completion(false, nil, Errors.EmptyAPIResponse)
                                    }

            }){
                (error) in
                print("Failed to get snapshot", error.localizedDescription)
                completion(false, nil, error)
        }
    }

    func retrieveData(atChild child: String,
                      whereKey key: String,
                      isEqualTo value: Any,
                      completion: @escaping (Bool, DataSnapshot?, Error?) -> Void) {

        self.dbRef.child(child)
            .queryOrdered(byChild: key)
            .queryEqual(toValue: value)
            .observe(.value, with: { (snapshot) in
                print("Snapshot exists", snapshot.exists())
                print("Snapshot hasChildren", snapshot.hasChildren())
                print("Snapshot has key", snapshot.key)

                if snapshot.childrenCount > 0 {
                    completion(true, snapshot, nil)
                } else {
                    completion(false, nil, Errors.EmptyAPIResponse)
                }

            }){
                (error) in
                print("Failed to get snapshot", error.localizedDescription)
                completion(false, nil, error)
        }
    }

    func add(data: [String: Any], atChild child: String, completion: @escaping (Bool, String?, Error?) -> Void) {
        self.dbRef.child(child).childByAutoId().setValue(data) {
            (error: Error?, ref: DatabaseReference) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, "Placeholder", nil)
            }
        }
    }
    
    func delete(atChild child: String, completion: @escaping (Bool, String?, Error?) -> Void) {
        self.dbRef.child(child).setValue(nil) {
            (error: Error?, ref: DatabaseReference) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, "Placeholder", nil)
            }
        }
    }

    func update(withData data: [String: Any], atChild child: String, completion: @escaping (Bool, String?, Error?) -> Void) {
        self.dbRef.child(child).updateChildValues(data) {
            (error: Error?, ref: DatabaseReference) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, "Placeholder", nil)
            }
        }
    }

    func closeConnections() {
        self.dbRef.removeAllObservers()
    }
}
