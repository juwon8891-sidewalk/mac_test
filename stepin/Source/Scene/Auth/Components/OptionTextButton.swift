import UIKit
import SDSKit
import SnapKit
import Then

enum PasswordOptionType {
    case alphabet
    case number
    case count
}

class OptionTextButton: UIButton {
    
    init(type: PasswordOptionType) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        self.backgroundColor = .stepinBlack100
        config.titleAlignment = .leading
        
        switch type {
        case .alphabet:
            config.attributedTitle = "auth_password_option_alphabet".localized().setAttributeString(textColor: .stepinWhite40, font: .suitRegularFont(ofSize: 12))
        case .number:
            config.attributedTitle = "auth_password_option_number".localized().setAttributeString(textColor: .stepinWhite40, font: .suitRegularFont(ofSize: 12))
        case .count:
            config.attributedTitle = "auth_password_option_count".localized().setAttributeString(textColor: .stepinWhite40, font: .suitRegularFont(ofSize: 12))
        }
        self.configuration = config
        
        self.titleLabel?.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
//            $0.height.equalTo(ScreenUtils.setWidth(value: 17))
        }
        self.titleLabel?.textAlignment = .left
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func changeSelectedColor() {
        var config = self.configuration
        let str = self.titleLabel?.attributedText?.string
        config?.attributedTitle = str!.setAttributeString(textColor: .SystemBlue, font: .suitRegularFont(ofSize: 12))
        self.configuration = config
    }
    
    internal func changeDefaultColor() {
        var config = self.configuration
        let str = self.titleLabel?.attributedText?.string
        config?.attributedTitle = str!.setAttributeString(textColor: .stepinWhite40, font: .suitRegularFont(ofSize: 12))
        self.configuration = config
    }
}
