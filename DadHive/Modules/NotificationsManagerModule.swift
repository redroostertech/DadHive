//
//  NotificationsManagerModule.swift
//  DadHive
//
//  Created by Michael Westbrooks on 2/8/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationsManagerModule {
    //static let shared = NotificationsManagerModule()
    private var notificationManager = UNUserNotificationCenter.current()
    var accessGranted: Bool!
    init() {
        checkNotificationPermissions { (access) in
//            self.notificationManager.delegate = self
            self.accessGranted = access
        }
    }

    func checkNotificationPermissions(_ completion: @escaping (Bool) -> Void) {
        completion(true)
//        self.notificationManager.requestAuthorization(options: <#T##UNAuthorizationOptions#>, completionHandler: <#T##(Bool, Error?) -> Void#>)
//        switch CLLocationManager.authorizationStatus() {
//        case .authorized: completion(true)
//        case .denied: completion(false)
//        case .notDetermined:
//            CLLocationManager().requestWhenInUseAuthorization()
//            completion(true)
//        default: completion(false)
//        }
    }

//    // 1
//    let content = UNMutableNotificationContent()
//    content.title = "New Journal entry 📌"
//    content.body = location.description
//    content.sound = .default
//
//    // 2
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//    let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
//
//    // 3
//    center.add(request, withCompletionHandler: nil)

}

//extension NotificationsManagerModule {
//
//}
