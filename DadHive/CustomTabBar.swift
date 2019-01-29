//
//  CustomTabBar.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/26/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import ChameleonFramework
import UserNotifications

class CustomTabBar:
    UITabBarController,
    UITabBarControllerDelegate
{

    let arrayOfImagesForTabBar = [
        "home",
        "message",
        "profile"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            if let error = error {
                print("There was an error granting permissions to notifications.")
                print(error)
            } else {
                print("Successfully granted permissions to notifications.")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension CustomTabBar {
    func setupTabBarItems() {
        guard let arrayOfTabBarItems = self.tabBar.items else { return }
        let selectedColor = AppColors.darkGreen
        let unselectedColor = UIColor.flatBlack
        var count = 0
        for tabBarItem in arrayOfTabBarItems {
            tabBarItem.tag = count
            tabBarItem.image = UIImage(named: arrayOfImagesForTabBar[count])
            tabBarItem.selectedImage = UIImage(named: arrayOfImagesForTabBar[count] + "-selected")
            tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: unselectedColor],
                                              for: .normal)
            tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedColor],
                                              for: .selected)
            count += 1
        }
    }
}
