import Foundation
import UIKit
import ChameleonFramework

let kAppName = "DadHive"
let kAdMobEnabled = false

let kAdMobApplicationID = "ca-app-pub-7049078720741277~8479527267"
let kAdMobInterstitialUnitID = "ca-app-pub-7049078720741277/2652485512"

let kCloudServerKey = "AAAAJ40j48U:APA91bGS-kcu3AOqWNE7v6OUhR0HuelyqaJBAgX7zZTS065O1-_zktiCiHxASFWsF3nx7EDdbi6otwhmxxeCHaGFEi2r0YFiaULG8otoKADnGiforxN6Pc-9X4POYWMoQhr_AMzb3te2"

let kJPEGImageQuality : CGFloat = 0.4
let kPagination : UInt = 10
let kMaxConcurrentImageDownloads = 2

let kIconSizeWidth : CGFloat = 32
let kIconSizeHeight : CGFloat = 32

let kPhotoShadowRadius : CGFloat = 10.0
let kPhotoShadowColor : UIColor = UIColor(white: 0, alpha: 0.1)
let kProfilePhotoSize : CGFloat = 100

let kTopOfScreen = UIScreen.main.bounds.minY
let kBottomOfScreen = UIScreen.main.bounds.maxY
let kFarLeftOfScreen = UIScreen.main.bounds.minX
let kFarRightOfScreen = UIScreen.main.bounds.maxX
let kWidthOfScreen = UIScreen.main.bounds.width
let kHeightOfScreen = UIScreen.main.bounds.height

let kSearchTextFieldHeight: CGFloat = 42
let kContainerViewHeightForMyPicks: CGFloat = 225
let kRemainingHeightForContainer: CGFloat = 250
let kAnimationDuration: Double = 2.0

let kPrimarySpacing: CGFloat = 8.0
let kPrimaryNoSpacing: CGFloat = 0.0
let kPrimaryCellHeight: CGFloat = 200.0

let kBarBtnSize = CGSize(width: 32.0, height: 32.0)
let kBarBtnPoint = CGPoint(x: 0.0, y: 0.0)

let kTextFieldPadding: CGFloat = 10.0

public let kTestBaseURL = "https://dadhive-test.herokuapp.com/" //"http://localhost:3000/"
public let kTestURL = kTestBaseURL + "api/v1/"
public let kLiveBaseURL = "https://dadhive.herokuapp.com/"
public let kLiveURL = kLiveBaseURL + "api/v1/"

//  MARK:- Collections
public let kConversations = "conversations"
public let kUsers = "users"
public let kMessages = "messages"
public let kMatches = "matches"
public let kMaxDistance = "maxDistance"
public let kAgeRange = "ageRange"

public let kLastUser = "lastUserKey"
public let kAuthorizedUser = "authorizedUser"
public let kNotificationsAccessCheck = "notificationsAccessCheck"

public var isLive = false
public var appColors: [UIColor] {
    return [ AppColors.lightGreen, AppColors.darkGreen ]
}
public var kAppCGColors: [CGColor] {
    return [ AppColors.lightGreen.cgColor, AppColors.darkGreen.cgColor ]
}

//  MARK:- Typography Strings
let kFontTitle = "AvenirNext-Bold"
let kFontSubHeader = "AvenirNext-Italic"
let kFontMenu = "AvenirNext-Regular"
let kFontBody = "AvenirNext-Regular"
let kFontCaption = "AvenirNext-UltraLight"
let kFontButton = "AvenirNext-Medium"
public var kFontSizeTitle: CGFloat { return 28 }
public var kFontSizeSubHeader: CGFloat { return 24 }
public var kFontSizeMenu: CGFloat { return 18 }
public var kFontSizeBody: CGFloat { return 18 }
public var kFontSizeCaption: CGFloat { return 12 }
public var kFontSizeButton: CGFloat { return 16 }

// MARK:- Observer Strings
let kLocationAccessCheckObservationKey = "observeLocationAccessCheck"
let kSaveLocationObservationKey = "saveLocationObservationKey"
let kNotificationAccessCheckObservationKey = "observeNotificationAccessCheck"
let kAddUserObservationKey = "addUserObservationKey"
let kLoadFirstUserObservationKey = "loadFirstUserObservationKey"

//  MARK:- Other Strings
let kLocationEnabled = "Location services enabled"
let kLocationDisabled = "Location services not enabled"
let kNotificationEnabled = "Notification services enabled"
let kNotificationDisabled = "Notification services not enabled"
let kLoginText = "Sign In"
let kSignUpText = "Sign Up"
let kLoginSwitchText = kLoginText
let kSignUpSwitchText = kSignUpText
let kMobileApiAgent = "mobile"

//  MARK:- Colors
let kEnabledTextColor: UIColor = .darkText
let kDisabledTextColor: UIColor = .gray

// MARK: - ViewController ID's
let kPermissionsVC = "PermissionsVC"
let kCustomTabBar = "CustomTabBar" // Primary container for main view of app
let kViewController = "ViewController" // View controller for login view
