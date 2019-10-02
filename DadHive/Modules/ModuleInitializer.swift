import Foundation
import IQKeyboardManagerSwift
import SDWebImage
import Sheeeeeeeeet

private var awsService: AWSService?
private var firebaseRepository: FIRRepository?
private var testDataGrabberModule: TestDataGrabberModule?
private var googleAdMobManager: GoogleAdMobManager?

class ModuleInitializer {
    
    static func setupApp() {
        print(" \(kAppName) | Module Handler Initialized")
        IQKeyboardManager.shared.enable = true
        
        // TODO: - Put some thought into whether or not the below modules need to be singletons.
        awsService = AWSService.shared
        firebaseRepository = FIRRepository.shared
        testDataGrabberModule = TestDataGrabberModule.shared
        googleAdMobManager = GoogleAdMobManager.shared

        setupActivitySheet()
    }

    deinit {
        print("Modulehandler is being deinitialized")
    }

  static func setupActivitySheet() {
    let item = ActionSheetItemCell.appearance()
    item.titleColor = .darkGray
    item.titleFont = .systemFont(ofSize: 15)
    item.subtitleColor = .lightGray
    item.subtitleFont = .systemFont(ofSize: 13)
    item.titleColor = .darkGray

    let title = ActionSheetTitleCell.appearance()
    ActionSheetTitle.height = 60
    title.titleColor = .black
    title.titleFont = .systemFont(ofSize: 16)
    title.separatorInset = .hiddenSeparator

    let sectionTitle = ActionSheetSectionTitleCell.appearance()
    ActionSheetSectionTitle.height = 20
    sectionTitle.titleColor = .black
    sectionTitle.titleFont = .systemFont(ofSize: 12)
    sectionTitle.subtitleFont = .systemFont(ofSize: 12)
    sectionTitle.separatorInset = .hiddenSeparator

    let selectItem = ActionSheetSelectItemCell.appearance()
    selectItem.selectedIcon = UIImage(named: "ic_checkmark")
    selectItem.unselectedIcon = UIImage(named: "ic_empty")

    let singleSelectItem = ActionSheetSingleSelectItemCell.appearance()
    singleSelectItem.selectedTitleColor = .black

    let multiSelectItem = ActionSheetMultiSelectItemCell.appearance()
    multiSelectItem.selectedTitleColor = .green

    let toggleItem = ActionSheetMultiSelectToggleItemCell.appearance()
    ActionSheetMultiSelectToggleItem.height = 20
    toggleItem.titleColor = .black
    toggleItem.titleFont = .systemFont(ofSize: 12)
    toggleItem.subtitleFont = .systemFont(ofSize: 12)
    toggleItem.separatorInset = .hiddenSeparator
    toggleItem.selectAllSubtitleColor = .darkGray
    toggleItem.deselectAllSubtitleColor = .red

    let linkItem = ActionSheetLinkItemCell.appearance()
    linkItem.linkIcon = UIImage(named: "ic_arrow_right")

    let button = ActionSheetButtonCell.appearance()
    button.titleFont = .systemFont(ofSize: 15)

    let okButton = ActionSheetOkButtonCell.appearance()
    okButton.titleColor = .black

    let cancelButton = ActionSheetCancelButtonCell.appearance()
    cancelButton.titleColor = .lightGray
  }
}
