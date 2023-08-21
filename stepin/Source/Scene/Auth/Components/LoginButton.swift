import UIKit
import SDSKit
import Foundation

enum SignInType {
    case google
    case faceBook
    case apple
    case email
}

class LoginButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(type: SignInType) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        
        config.background.backgroundColor = .PrimaryWhiteNormal
        config.background.cornerRadius = 30.adjusted
        imageView?.contentMode = .scaleAspectFill
        config.background.strokeColor = .PrimaryWhiteNormal
        config.background.strokeWidth = 2.adjusted

        switch type {
        case .google:
            config.image = SDSIcon.icLoginGoogle
            config.attributedTitle = "auth_google_button_title".localized().setAttributeString(textColor: .PrimaryBlackNormal, font: SDSFont.body.font)
            self.configuration = config
        case .faceBook:
            config.image = SDSIcon.icLoginFacebook
            config.attributedTitle = "auth_facebook_button_title".localized().setAttributeString(textColor: .PrimaryBlackNormal, font: SDSFont.body.font)
            self.configuration = config
        case .apple:
            config.image = SDSIcon.icLoginApple
            config.attributedTitle = "auth_apple_button_title".localized().setAttributeString(textColor: .PrimaryBlackNormal, font: SDSFont.body.font)
            self.configuration = config
        case .email:
            config.image = SDSIcon.icLoginEmail
            config.attributedTitle = "auth_email_button_title".localized().setAttributeString(textColor: .PrimaryWhiteNormal, font: SDSFont.body.font)
            config.background.backgroundColor = .PrimaryBlackNormal
            self.configuration = config
        }


        imageView?.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24.adjusted)
            $0.leading.equalToSuperview().offset(20.adjusted)
        }
        titleLabel?.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo((imageView?.snp.trailing)!).offset(17.adjusted)
            $0.trailing.equalToSuperview().inset(55.adjusted)
        }

        
        titleLabel?.textAlignment = .center
    }
}
