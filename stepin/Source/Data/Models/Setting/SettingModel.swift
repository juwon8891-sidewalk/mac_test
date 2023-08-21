import Foundation
import RxDataSources

struct SettingModel {
    let title: String
    let description: String
    let type: SettingCellType
}

struct SettingTableviewDataSection {
    var items: [SettingModel]
}

extension SettingTableviewDataSection: SectionModelType {
    typealias Item = SettingModel
    
    init(original: SettingTableviewDataSection, items: [SettingModel]) {
        self = original
        self.items = items
    }
}


let settingModel = [SettingTableviewDataSection(items: [
//    SettingModel(title: "setting_push_title".localized(), description: "setting_push_description".localized(), type: .toggleCell),
    SettingModel(title: "setting_Manage_blocked_title".localized(), description: "", type: .arrowCell),
    SettingModel(title: "setting_terms_title".localized(), description: "", type: .arrowCell),
    SettingModel(title: "setting_privacy_title".localized(), description: "", type: .arrowCell),
    SettingModel(title: "setting_EULA_title".localized(), description: "", type: .arrowCell),
    SettingModel(title: "setting_news_boards_title".localized(), description: "", type: .arrowCell),
//    SettingModel(title: "setting_enter_code_title".localized(), description: "", type: .arrowCell), 추 후 추가
    SettingModel(title: "setting_app_version_title".localized(), description: "", type: .versionCell),
    SettingModel(title: "setting_logout_title".localized(), description: "", type: .logoutCell),
    SettingModel(title: "", description: "setting_deleteAccount_description".localized(), type: .withdrawlCell)
])]
