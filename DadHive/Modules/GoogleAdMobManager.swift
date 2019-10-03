import Foundation
import GoogleMobileAds

class GoogleAdMobManager: NSObject {
    static let shared = GoogleAdMobManager()

    var interstitial: GADInterstitial!
    var banner: GADBannerView!

    private override init() {
        print(" \(kAppName) | GoogleAdMobManager Handler Initialized")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        super.init()
        interstitial = createAndLoadInterstitial()
        banner = createAndLoadBanner()
    }

    private func createAndLoadInterstitial() -> GADInterstitial {
      let ad = GADInterstitial(adUnitID: kAdMobInterstitialUnitID)
      ad.delegate = self
      let adRequest = GADRequest()
      if !isLive {
        adRequest.testDevices = [kGADSimulatorID, "e74c3e5db67134eb3dfc9e5182f9cd6c"]
      }
      ad.load(GADRequest())
      return ad
    }

  private func createAndLoadBanner() -> GADBannerView {
    let ad = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    ad.adUnitID = kAdMobBannerViewlUnitID
    ad.delegate = self
    let adRequest = GADRequest()
    if !isLive {
      adRequest.testDevices = [kGADSimulatorID, "e74c3e5db67134eb3dfc9e5182f9cd6c"]
    }
    ad.load(GADRequest())
    return ad
  }

    func showInterstitialAd(on vc: UIViewController) {
      if self.interstitial.isReady {
        self.interstitial.present(fromRootViewController: vc)
      } else {
        print("Ad wasn't ready")
      }
    }

  func showBannerView(in vc: UIViewController, on view: UIView) {
    banner.rootViewController = vc
    banner.frame = view.frame
    view.addSubview(banner)
  }
}

extension GoogleAdMobManager: GADInterstitialDelegate {
  /// Tells the delegate an ad request succeeded.
  func interstitialDidReceiveAd(_ ad: GADInterstitial) {
    print("interstitialDidReceiveAd")
  }

  /// Tells the delegate an ad request failed.
  func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
    print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }

  /// Tells the delegate that an interstitial will be presented.
  func interstitialWillPresentScreen(_ ad: GADInterstitial) {
    print("interstitialWillPresentScreen")
  }

  /// Tells the delegate the interstitial is to be animated off the screen.
  func interstitialWillDismissScreen(_ ad: GADInterstitial) {
    print("interstitialWillDismissScreen")
  }

  /// Tells the delegate the interstitial had been animated off the screen.
  func interstitialDidDismissScreen(_ ad: GADInterstitial) {
    print("interstitialDidDismissScreen")
    interstitial = createAndLoadInterstitial()
  }

  /// Tells the delegate that a user click will open another app
  /// (such as the App Store), backgrounding the current app.
  func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
    print("interstitialWillLeaveApplication")
  }
}

extension GoogleAdMobManager: GADBannerViewDelegate {
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("adViewDidReceiveAd")
  }

  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: GADBannerView,
              didFailToReceiveAdWithError error: GADRequestError) {
    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }

  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("adViewWillPresentScreen")
  }

  /// Tells the delegate that the full-screen view will be dismissed.
  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("adViewWillDismissScreen")
  }

  /// Tells the delegate that the full-screen view has been dismissed.
  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("adViewDidDismissScreen")
  }

  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    print("adViewWillLeaveApplication")
  }
}
