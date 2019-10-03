//
//  NotificationsManagerModule.swift
//  DadHive
//
//  Created by Michael Westbrooks on 2/8/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import RRoostSDK

class NotificationsManagerModule: NSObject {
    static let shared = NotificationsManagerModule()
    private var notificationManager = UNUserNotificationCenter.current()
    private var checkAccessCount = 0
    var accessGranted: Bool!

    private override init() { }

    func getNotificationAccess(_ completion: @escaping (Bool) -> Void) {
        getNotificationSettings { (access) in
            completion(access)
        }
    }

    func checkNotificationPermissions(_ completion: @escaping (Bool) -> Void) {
        getNotificationSettings { (access) in
            if (!access) {
                self.notificationManager.requestAuthorization(options: [.alert, .badge, .sound]) {
                    (success, error) in
                    if let _ = error {
                        completion(false)
                    } else {
                        completion(access)

                    }
                }
            } else {
                completion(true)
            }
        }
    }

    private func getNotificationSettings(_ completion: @escaping (Bool) -> Void) {
        self.notificationManager.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized: completion(true)
            case .denied, .notDetermined: completion(false)
            default: completion(false)
            }
        }
    }

    func createNotificationRequest(withID id: String, title: String, andBody body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        addNotificationRequest(request: request)
    }

    func addNotificationRequest(request: UNNotificationRequest) {
        self.notificationManager.add(request, withCompletionHandler: nil)
    }
    
}

extension NotificationsManagerModule {

}
