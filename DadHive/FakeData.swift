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

        let fakeGeoIndex = Int.random(in: 0...fakeGeoPoints.count - 1)
        let long =  fakeGeoPoints[fakeGeoIndex]["Long"]
        let lat = fakeGeoPoints[fakeGeoIndex]["Lat"]
        let uid = Utilities.randomString(length: 25)
        
        let userData: [String: Any?] = [
            "email": "test\(count)@gmail.com",
            "name": "Test User \(count)",
            "uid": uid,
            "createdAt": Date().toString(format: CustomDateFormat.timeDate.rawValue),
            "type": 1,
            "currentPage": 1,
            "preferredCurrency": "USD",
            "notifications" : false,
            "maxDistance" : 25.0,
            "ageRangeId": nil,
            "ageRangeMin": nil,
            "ageRangeMax": nil,
            "initialSetup" : false,
            "userProfilePicture_1_url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg",
            "userProfilePicture_1_meta": nil,
            "userProfilePicture_2_url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg",
            "userProfilePicture_2_meta": nil,
            "userProfilePicture_3_url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg",
            "userProfilePicture_3_meta": nil,
            "userProfilePicture_4_url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg",
            "userProfilePicture_4_meta": nil,
            "userProfilePicture_5_url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg",
            "userProfilePicture_5_meta": nil,
            "userProfilePicture_6_url": "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg",
            "userProfilePicture_6_meta": nil,
            "dob": nil,
            "addressLine1" : nil,
            "addressLine2" : nil,
            "addressLine3" : nil,
            "addressLine4" : nil,
            "addressCity" : nil,
            "addressState" : nil,
            "addressZipCode" : nil,
            "addressLong" : long,
            "addressLat" : lat,
            "addressCountry": nil,
            "addressDescription": nil,
            "bio": nil,
            "jobTitle": nil,
            "companyName": nil,
            "schoolName": nil,
            "kidsCount": 0,
            "kidsNames": nil,
            "kidsAges": nil,
            "kidsBio": nil,
            "questionOneTitle": nil,
            "questionOneResponse": nil,
            "questionTwoTitle": nil,
            "questionTwoResponse": nil,
            "questionThreeTitle": nil,
            "questionThreeResponse": nil,
            "canSwipe": true,
            "nextSwipeDate": nil,
            "profileCreation" : false
        ]
        FIRFirestoreDB.shared.add(data: userData, to: kUsers) { (success, results, error) in
            let parameters: [String: Any] = [
                "userId": uid,
                "latitude": lat,
                "longitude": long
            ]
            APIRepository().performRequest(path: Api.Endpoint.saveLocation, method: .post, parameters: parameters) { (response, error) in

                self.generateFakeUserAccounts(count - 1)

                guard error == nil else {
                    return print(DadHiveError.jsonResponseError.rawValue)
                }

                guard let res = response as? [String: Any] else {
                    return print(DadHiveError.jsonResponseError.rawValue)
                }

                guard let data = res["data"] as? [String: Any] else {
                    return print(DadHiveError.jsonResponseError.rawValue)
                }

                guard let usersData = Users(JSON: data) else {
                    return print(DadHiveError.jsonResponseError.rawValue)
                }

                print(usersData)
            }
        }
    }

    func deleteFakeUsers() {
        FIRFirestoreDB.shared.deleteAllUsers()
        FIRAuthentication.shared.signout()
    }
}
