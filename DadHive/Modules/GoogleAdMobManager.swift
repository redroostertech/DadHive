import Foundation
import GoogleMobileAds

class GoogleAdMobManager {
    static let shared = GoogleAdMobManager()
    private init() {
        print(" \(kAppName) | GoogleAdMobManager Handler Initialized")
        GADMobileAds.configure(withApplicationID: kAdMobApplicationID)
    }
   
    func generateInterstitialAd(_ delegate: GADInterstitialDelegate) -> GADInterstitial {
        let ad = GADInterstitial(adUnitID: kAdMobInterstitialUnitID)
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        ad.load(adRequest)
        ad.delegate = delegate
        return ad
    }
}
