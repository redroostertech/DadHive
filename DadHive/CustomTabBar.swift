//
//  CustomTabBar.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/26/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import ChameleonFramework

class CustomTabBar:
    UITabBarController,
    UITabBarControllerDelegate
{

    let arrayOfImagesForTabBar = [
        "home",
        "message",
        "profile",
        "home"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
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
            tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor],
                                              for: .normal)
            tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor],
                                              for: .selected)
            count += 1
        }
    }
}
