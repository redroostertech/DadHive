import UIKit
import ChameleonFramework
import RRoostSDK
import FirebaseInstanceID

private let arrayOfImagesForTabBar = [ "main", "find", "notification", "user"]

class CustomTabBar: UITabBarController, UITabBarControllerDelegate {

    private let defaultCenter = NotificationCenter.default

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()

      guard let currentuser = CurrentUser.shared.user else { return }

      NotificationsManagerModule.shared.checkNotificationPermissions { access in

        currentuser.setDeviceID(forState: access, completion: { (error, deviceIDSaved) in
          currentuser.setNotificationToggle(deviceIDSaved)
        })
      }

        defaultCenter.addObserver(self, selector: #selector(loadData(_:)), name: Notification.Name(kUpdateNotificationCount), object: nil)
        defaultCenter.addObserver(self, selector: #selector(resetCount(_:)), name: Notification.Name(kResetNotificationCount), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc private func loadData(_ notification: Notification) {
        guard let currentuser = CurrentUser.shared.user, let notifications = currentuser.settings?.notifications, (notifications) else { return }
        guard let userinfo = notification.userInfo else { return }
        print("Notification loaded : \(userinfo)")
        guard let arrayOfTabBarItems = self.tabBar.items else { return }
        arrayOfTabBarItems[2].badgeValue = "New"
    }

    @objc private func resetCount(_ notification: Notification) {
        let resetCount = 0
        UIApplication.shared.applicationIconBadgeNumber = resetCount
        DefaultsManager().setDefault(withData: resetCount, forKey: kNotificationCount)
        guard let userinfo = notification.userInfo else { return }
        print("Notification loaded : \(userinfo)")
        guard let arrayOfTabBarItems = self.tabBar.items else { return }
        arrayOfTabBarItems[2].badgeValue = nil
    }
    
    // MARK: - Private member functions
    private func setupTabBarItems() {
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
