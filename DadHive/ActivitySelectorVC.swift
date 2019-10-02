import UIKit
import LGButton
import RRoostSDK

protocol ActivitySelectorDelegate: class {
    func didStartHive(_ viewController: UIViewController, button: LGButton)
    func didFindHive(_ viewController: UIViewController, button: LGButton)
    func didCancel(_ viewController: UIViewController, button: LGButton)
}

class ActivitySelectorVC: UIViewController {
    
    @IBOutlet weak var startHiveButton: LGButton!
    @IBOutlet weak var findHiveButton: LGButton!
    @IBOutlet weak var cancelButton: LGButton!
    
    weak var activitySelectorDelegate: ActivitySelectorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverride))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissOverride() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startHiveAction(_ sender: LGButton) {
        dismiss(animated: true, completion: {
            self.activitySelectorDelegate?.didStartHive(self, button: sender)
        })
    }
    
    @IBAction func findHiveAction(_ sender: LGButton) {
        dismiss(animated: true, completion: {
            self.activitySelectorDelegate?.didFindHive(self, button: sender)
        })
    }
    
    @IBAction func cancelAction(_ sender: LGButton) {
        dismiss(animated: true, completion: {
            self.activitySelectorDelegate?.didCancel(self, button: sender)
        })
    }
}
