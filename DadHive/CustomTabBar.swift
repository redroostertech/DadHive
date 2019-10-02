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

        var device_id = ""
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            device_id = "\(result.token)"
            self.addRemoteDeviceID(device_id: device_id)
          }
        }
        defaultCenter.addObserver(self, selector: #selector(loadData(_:)), name: Notification.Name(kUpdateNotificationCount), object: nil)
        defaultCenter.addObserver(self, selector: #selector(resetCount(_:)), name: Notification.Name(kResetNotificationCount), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc private func loadData(_ notification: Notification) {
        guard let userinfo = notification.userInfo else { return }
        print("Notification loaded : \(userinfo)")
        guard let arrayOfTabBarItems = self.tabBar.items else { return }
        arrayOfTabBarItems[2].badgeValue = "NEW"
    }

    func addRemoteDeviceID(device_id:String){
      guard let currentuser = CurrentUser.shared.user, let notifications =  currentuser.settings?.notifications, (notifications) else { return }

      currentuser.change(type: "deviceId", value: device_id) { error in
        if let err = error {
          print("There was an error saving device id.")
        } else {
          print("Device ID saved")
        }
      }
    }

    @objc private func resetCount(_ notification: Notification) {
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
