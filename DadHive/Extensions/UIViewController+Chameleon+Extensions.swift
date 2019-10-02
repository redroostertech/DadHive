//
//  UIViewController+Chameleon+Extensions.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/11/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ChameleonFramework
import SVProgressHUD
import APESuperHUD

// MARK: - APESuperHUD extension methods
extension UIViewController {
  func setupSuperHUD() {
    HUDAppearance.cornerRadius = 10
    HUDAppearance.animateInTime = 1.0
    HUDAppearance.animateOutTime = 1.0
    HUDAppearance.iconColor = UIColor.flatGreen
    HUDAppearance.titleTextColor =  UIColor.flatGreen
    HUDAppearance.loadingActivityIndicatorColor = UIColor.flatGreen
    HUDAppearance.cancelableOnTouch = true
    HUDAppearance.iconSize = CGSize(width: kIconSizeWidth, height: kIconSizeHeight)
    HUDAppearance.messageFont = UIFont(name: kFontBody, size: kFontSizeBody) ?? UIFont.systemFont(ofSize: kFontSizeBody, weight: .regular)
    HUDAppearance.titleFont = UIFont(name: kFontTitle, size: kFontSizeTitle) ?? UIFont.systemFont(ofSize: kFontSizeTitle, weight: .bold)
  }

  func showHUD(_ text: String = "Finding Users") {
    APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: 4.0), title: nil, message: text, completion: nil)
  }

  func showHUD(_ text: String = "Finding Users", withDuration duration: TimeInterval? = 4.0) {
    APESuperHUD.show(style: .icon(image: UIImage(named: "dadhive-hive")!, duration: duration), title: nil, message: text, completion: nil)
  }

  func dismissHUD() {
    APESuperHUD.dismissAll(animated: true)
  }
}

// MARK: - SVProgressHUD extension methods
extension UIViewController {
  func showError(_ error: String, withDelay delay: TimeInterval = 3.0) {
    SVProgressHUD.showError(withStatus: error)
    SVProgressHUD.dismiss(withDelay: delay)
  }

  func showErrorAlert(message: String?) {
    SVProgressHUD.showError(withStatus: message ?? "")
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.setDefaultMaskType(.gradient)
    SVProgressHUD.setMinimumDismissTimeInterval(1)
  }

  func showErrorAlert(_ error: DadHiveError) {
    SVProgressHUD.showError(withStatus: error.rawValue)
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.setDefaultMaskType(.gradient)
    SVProgressHUD.setMinimumDismissTimeInterval(1)
  }

  func showAlertErrorIfNeeded(error: Error?) {
    if let e = error {
      showErrorAlert(message: e.localizedDescription)
    } else {
      SVProgressHUD.dismiss()
    }
  }

  func showHUD() {
    SVProgressHUD.show()
    UIApplication.shared.beginIgnoringInteractionEvents()
    SVProgressHUD.setBackgroundColor(AppColors.darkGreen)
    SVProgressHUD.setForegroundColor(UIColor.white)
  }

  func hideHUD() {
    if SVProgressHUD.isVisible() {
      SVProgressHUD.dismiss()
    }
    UIApplication.shared.endIgnoringInteractionEvents()
  }

}

// MARK: - ChameleonFramework extension methods
extension UIViewController {
  func hideNavigationBarHairline() {
    if let navController = self.navigationController {
      navController.hidesNavigationBarHairline = true
    }
  }
}
