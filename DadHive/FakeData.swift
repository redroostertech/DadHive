//
//  FakeData.swift
//  DadHive
//
//  Created by Michael Westbrooks on 2/3/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import Firebase

class FakeDataGenerator {
    func generateFakeUserAccounts(_ count: Int) {
        guard count > 0 else {
            print("Completed adding fake users")
            return
        }
        
        let userData: [String: Any] = [
            "email": "test\(count)@gmail.com",
            "name": [
                "fullName" : "Test User \(count)"
            ],
            "uid": Utilities.randomString(length: 25),
            "createdAt": Date().toString(format: CustomDateFormat.timeDate.rawValue),
            "type": 1,
            "settings": [
                "notifications" : false,
                "location" : nil,
                "maxDistance" : 25
            ],
            "profileCreation" : false,
            "userProfilePictures" : [
                [
                    "id": Utilities.randomString(length: 25),
                    "url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
                ],[
                    "id": Utilities.randomString(length: 25),
                    "url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
                ],[
                    "id": Utilities.randomString(length: 25),
                    "url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
                ]
            ],
            "userInformation" : [
                "age" : [
                    "info": Int.random(in: 22...42),
                    "title": "Age",
                    "type": "age"
                ],
                "bio" : [
                    "info": "Random bio",
                    "title": "About Me",
                    "type": "bio"
                ],
                "jobTitle" : [
                    "info": "Random Job Title",
                    "title": "Job Title",
                    "type": "jobTitle"
                ],
                "kidsNames" : [
                    "info": "Christian and Jack",
                    "title": "Kids Names",
                    "type": "kidsNames"
                ],
                "location" : [
                    "info": "Random City, State",
                    "title": "Location",
                    "type": "location"
                ]
            ]
        ]
        if let user = User(JSON: userData) {
            FIRFirestoreDB.shared.add(data: user.toJSON(), to: kUsers) { (success, results, error) in
                if
                    let documentID = results,
                    let lat = fakeGeoPoints[Int.random(in: 0...fakeGeoPoints.count - 1)]["Lat"],
                    let long = fakeGeoPoints[Int.random(in: 0...fakeGeoPoints.count - 1)]["Long"] {

                    FIRFirestoreDB.shared.addGeofireObject(forDocumentID: documentID, atLat: lat, andLong: long, completion: {
                        print("Successfully updated user data & added a geofire obbject.")
                        self.generateFakeUserAccounts(count - 1)
                    })
                } else {
                    print("Error with geofire, but continue process")
                    self.generateFakeUserAccounts(count - 1)
                }

            }
        }
    }

    func deleteFakeUsers() {
        FIRFirestoreDB.shared.deleteAllUsers()
        FIRAuthentication.shared.signout()
    }
}
