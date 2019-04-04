//
//  UIViewController+Ext.swift
//  Gumbo
//
//  Created by Michael Westbrooks on 5/19/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import ChameleonFramework

extension UIViewController {
    
    func hideNavigationBarHairline() {
        if let navController = self.navigationController {
            navController.hidesNavigationBarHairline = true
        }
    }
    
    func hideNavigationBar() {
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = true
        }
    }
    
    func unHideNavigationBar() {
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = false
        }
    }
    
    func showNavigationBar() {
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = false
        }
    }
    
    func clearNavigationBackButtonText() {
        if (self.navigationController != nil) {
            self.navigationItem.title = ""
        }
    }
    
    func updateNavigationBar(withBackgroundColor bgColor: UIColor?,
                             tintColor: UIColor?,
                             andText text: String?) {
        if (self.navigationController != nil) {
            self.navigationController?.navigationBar.isTranslucent = false
            if bgColor != nil {
                self.navigationController?.navigationBar.barTintColor = bgColor!
            }
            if tintColor != nil {
                self.navigationController?.navigationBar.tintColor = tintColor!
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: tintColor]
            }
            if text != nil {
                updateNavigationBar(title: text!)
            } else {
                clearNavigationBackButtonText()
            }
        }
    }
    
    func updateNavigationBar(title: String) {
        if (self.navigationController != nil) {
            self.navigationItem.title = title
        }
    }
    
    func updateNavigationBar(withButton button: UIButton) {
        if (self.navigationController != nil) {
            let button = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = button
        }
    }
    
    func updateNavigationBar(withButton buttons: [UIButton]) {
        if (self.navigationController != nil) {
            var btns = [UIBarButtonItem]()
            for button in buttons {
                let btn = UIBarButtonItem(customView: button)
                btns.append(btn)
            }
            self.navigationItem.rightBarButtonItems = btns
        }
    }
    
    func navigateToView(withID vid: String, fromStoryboard sid: String = "Main") {
        let storyboard = UIStoryboard(name: sid, bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: vid)
        UIApplication.shared.keyWindow?.rootViewController = viewcontroller
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    func pushToView(withID vid: String, fromStoryboard sid: String = "Main") {
        let storyboard = UIStoryboard(name: sid, bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: vid)
        if (self.navigationController != nil) {
            self.navigationController!.pushViewController(viewcontroller, animated: true)
        } else {
            self.present(viewcontroller, animated: true, completion: nil)
        }
    }
    
    func pushToView(withViewController viewcontroller: UIViewController) {
        if (self.navigationController != nil) {
            self.navigationController!.pushViewController(viewcontroller, animated: true)
        } else {
            self.present(viewcontroller, animated: true, completion: nil)
        }
    }
    
    func popViewController(to vid: String? = nil, fromStoryboard sid: String? = nil){
        guard let idForViewController = vid, let idForStoryboard = sid else {
            if (self.navigationController != nil) {
                self.navigationController!.popViewController(animated: true)
            }
            return
        }
        let storyboard = UIStoryboard(name: idForStoryboard, bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: idForViewController)
        if (self.navigationController != nil) {
            self.navigationController!.popToViewController(viewcontroller,
                                                           animated: true)
        }
    }
    
    func popViewController(withViewController viewcontroller: UIViewController){
        if (self.navigationController != nil) {
            self.navigationController!.popToViewController(viewcontroller,
                                                           animated: true)
        } else {
            self.present(viewcontroller, animated: true, completion: nil)
        }
    }
    
    func dismissViewController() {
        self.dismiss(animated: true,
                     completion: nil)
    }
    
//    func showHUD() {
//        SVProgressHUD.show()
//        SVProgressHUD.setBackgroundColor(UIColor.orange)
//        SVProgressHUD.setForegroundColor(UIColor.white)
//    }

    func showError(_ error: String, withDelay delay: TimeInterval = 3.0) {
        SVProgressHUD.showError(withStatus: error)
        SVProgressHUD.dismiss(withDelay: delay)
    }

    func scrollToTop(of tableView: UITableView, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if tableView.visibleCells.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            completion()
        }
    }
    
    func scrollToBottom(of tableView: UITableView, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
            }
            completion()
        }
    }
    
    func setBackground(_ imageName: String, onView view: UIView) {
        if let view = self.view {
            let image = UIImage(named: imageName)
            let imageView = UIImageView(frame: view.frame)
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            view.addSubview(imageView)
            view.sendSubview(toBack: imageView)
        }
    }
    
    func setBackground(_ color: UIColor, onView view: UIView) {
        if let view = self.view {
            view.backgroundColor = color
        }
    }

    func EmptyMessage(tableView:UITableView, message:String, viewController:UIViewController) {
        print("Setting empty message")
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = .none;
        print("message set")
    }
    
//    func setBackgroundWithPrimaryGradient() {
//        if let view = self.view {
//            view.addPrimaryGradientToBackground()
//        }
//    }
//    
//    func setBackgroundWithSecondaryGradient() {
//        if let view = self.view {
//            view.addSecondaryGradientToBackground()
//        }
//    }

    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: 16, y: self.view.frame.size.height-150, width: self.view.frame.size.width - 32, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 2
        toastLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
