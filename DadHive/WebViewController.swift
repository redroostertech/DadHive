//
//  WebViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/26/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

  @IBOutlet weak var webViewContainer: UIView!

  var webView: Any?

  override func viewDidLoad() {
    super.viewDidLoad()
    DispatchQueue.main.async {
      self.navigationController?.navigationBar.tintColor = .white
      self.hideNavigationBarHairline()
      self.setupSuperHUD()
    }

    if #available(iOS 11.0, *) {
      webView = WKWebView(frame: webViewContainer.frame)
      webViewContainer.addSubview(webView as! WKWebView)
    } else {
      webView = UIWebView(frame: webViewContainer.frame)
      webViewContainer.addSubview(webView as! UIWebView)
    }
  }

  func loadUrl(_ url: URL) {
    guard let webview = webView else { return }
    if let wb = webview as? WKWebView {
      wb.loadFileURL(url, allowingReadAccessTo: url)
    }

    if let wb = webview as? UIWebView {
      let request = URLRequest(url: url)
      wb.loadRequest(request)
    }
  }

}
