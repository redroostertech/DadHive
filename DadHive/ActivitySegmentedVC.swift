//
//  ActivitySegmentedVC.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/22/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import RRoostSDK

class ActivitySegmentedVC: UIViewController {

  var pageMenu : CAPSPageMenu?
  var myPostsVC: ActivityViewController?
  var otherPostsVC: OtherPostsActivityViewController?
  var controllerArray : [UIViewController] = []
  var selectedController: UIViewController?

    override func viewDidLoad() {
      super.viewDidLoad()

      DispatchQueue.main.async {
        self.navigationController?.navigationBar.tintColor = .white
        self.hideNavigationBarHairline()
      }
      if let myPostsVC = UIStoryboard(name: kMainStoryboard, bundle: nil).instantiateViewController(withIdentifier: "ActivityViewController") as? ActivityViewController {
        myPostsVC.title = "My Posts"
        myPostsVC.parentVC = self
        controllerArray.append(myPostsVC)
        self.myPostsVC = myPostsVC
      }

      if let otherPostsVC = UIStoryboard(name: kMainStoryboard, bundle: nil).instantiateViewController(withIdentifier: "OtherPostsActivityViewController") as? OtherPostsActivityViewController {
        otherPostsVC.title = "Posts I've Liked"
        otherPostsVC.parentVC = self
        controllerArray.append(otherPostsVC)
        self.otherPostsVC = otherPostsVC
      }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let parameters: [CAPSPageMenuOption] = [
      .menuItemSeparatorWidth(0),
      .useMenuLikeSegmentedControl(true),
      .menuItemSeparatorPercentageHeight(0),
      .scrollMenuBackgroundColor(.white),
      .viewBackgroundColor(.white),
      .selectionIndicatorColor(DadHiveGreen),
      .selectionIndicatorHeight(3.0),
      .selectedMenuItemLabelColor(DadHiveGreen),
      .unselectedMenuItemLabelColor(UIColor.darkText),
      .menuHeight(50.0),
      .menuItemWidth(90.0),
      .centerMenuItems(true)
    ]

    pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
    pageMenu!.delegate = self
    self.view.addSubview(pageMenu!.view)

    if let controller = selectedController as? ActivityViewController {
      controller.reloadTable()
    }

    if let controller = selectedController as? OtherPostsActivityViewController {
      controller.reloadTable()
    }

  }

}

// MARK: - CAPSPageMenuDelegate
extension ActivitySegmentedVC: CAPSPageMenuDelegate {
  func didMoveToPage(_ controller: UIViewController, index: Int) {
    selectedController = controller
    if let controller = selectedController as? ActivityViewController {
      controller.reloadTable()
    }

    if let controller = selectedController as? OtherPostsActivityViewController {
      controller.reloadTable()
    }
  }
}
