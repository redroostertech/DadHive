import Foundation
import IQKeyboardManagerSwift
import SDWebImage

private var awsService: AWSService?
private var firebaseRepository: FIRRepository?
private var testDataGrabberModule: TestDataGrabberModule?
private var googleAdMobManager: GoogleAdMobManager?
private var notificationManager: NotificationsManagerModule?

class ModuleInitializer {
    
    static func setupApp() {
        print(" \(kAppName) | Module Handler Initialized")
        IQKeyboardManager.shared.enable = true
        
        // TODO: - Put some thought into whether or not the below modules need to be singletons.
        awsService = AWSService.shared
        firebaseRepository = FIRRepository.shared
        testDataGrabberModule = TestDataGrabberModule.shared
        googleAdMobManager = GoogleAdMobManager.shared
        notificationManager = NotificationsManagerModule.shared
    }

    deinit {
        print("Modulehandler is being deinitialized")
    }
}
