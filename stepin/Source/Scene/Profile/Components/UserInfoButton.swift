import UIKit
import SnapKit
import Then

enum UserInfoButtonType {
    case dances
    case followers
    case following
}

class UserInfoButton: UIButton {
    
    init(type: UserInfoButtonType) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.titleAlignment = .center
        
        switch type {
        case .dances:
            config.attributedTitle = "mypage_dances_button_title".localized().setAttributeString(textColor: .stepinWhite100, font: .suitLightFont(ofSize: 12))
        case .followers:
            config.attributedTitle = "mypage_followers_button_title".localized().setAttributeString(textColor: .stepinWhite100, font: .suitLightFont(ofSize: 12))
        case .following:
            config.attributedTitle = "mypage_following_button_title".localized().setAttributeString(textColor: .stepinWhite100, font: .suitLightFont(ofSize: 12))
        }
        self.configuration = config
        
        self.titleLabel?.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
    }
    private func convertNumber(num: Int) -> String {
        if num > 1000 && num < 1000000 {
            return "\(num / 1000)K"
        }
        else if num >= 1000000 {
            return "\(num / 1000000)M"
        } else {
            return "\(num)"
        }
    }
    internal func setSubtitleTransform() {
        self.subtitleLabel?.snp.makeConstraints {
            $0.top.equalTo(titleLabel!.snp.bottom).offset(ScreenUtils.setWidth(value: 8))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
    }
    
    internal func setSubTitle(subTitle: Int) {
        var config = self.configuration
        let subTitle = convertNumber(num: subTitle).setAttributeString(textColor: .stepinWhite100, font: .suitExtraBoldFont(ofSize: 12))
        config?.attributedSubtitle = subTitle
        self.configuration = config
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
