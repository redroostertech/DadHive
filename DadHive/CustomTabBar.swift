import UIKit
import ChameleonFramework

private let arrayOfImagesForTabBar = [ "home", "message", "profile", "home"]

class CustomTabBar: UITabBarController, UITabBarControllerDelegate {

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
