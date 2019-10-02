//
//  ReportViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/23/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

private var apiRepository = APIRepository()

class ReportViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()

    textView.delegate = self

    DispatchQueue.main.async {
      self.navigationController?.navigationBar.tintColor = .white
      self.hideNavigationBarHairline()
      self.setupSuperHUD()
    }

  }

  @IBAction private func cancel(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction private func post(_ sender: UIButton) {

    guard let currentuser = CurrentUser.shared.user else { return }

    guard textView.text != "Start typing", textView.text != "" else {
      self.showHUD("You forgot something.")
      return
    }

    DispatchQueue.main.async {
      self.showHUD(kCreatingPost)
    }

    let params: [String: Any] = [
      "senderId": currentuser.uid ?? "",
      "type": "1",
      "description": textView.text!,
      "categories": []
    ]
    apiRepository.performRequest(path: Api.Endpoint.addPost, method: .post, parameters: params) { (response, error) in

      DispatchQueue.main.async {
        self.dismissHUD()
      }

      guard error == nil else {
        print("There was an error at the api.")
        return self.showHUD(kGenericError)
      }

      guard let res = response as? [String: Any] else {
        print("Response was unable to be retrieved.")
        return self.showHUD(kGenericError)
      }

      guard let data = res["data"] as? [String: Any], let notifs = NotificationResponse(JSON: data) else {
        print("Data attribute does not exist for the response.")
        return self.showHUD(kGenericError)
      }

      self.showHUD("Done")
      self.dismiss(animated: true, completion: nil)
    }
  }
}

extension ReportViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Start typing" {
      textView.text = ""
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "Start typing" || textView.text == "" {
      textView.text = ""
    }
  }
}

