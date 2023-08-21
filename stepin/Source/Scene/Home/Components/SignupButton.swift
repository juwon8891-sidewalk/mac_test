import UIKit
import SDSKit
import Foundation

class SignupButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.addSubviews([signupLabel])
        var config = UIButton.Configuration.plain()
        
        self.snp.makeConstraints {
            $0.width.equalTo(114.adjusted)
            $0.height.equalTo(30.adjusted)
        }
        
        config.background.backgroundColor = .clear
        config.background.cornerRadius = 15.adjusted
        config.background.strokeColor = .PrimaryWhiteNormal
        config.background.strokeWidth = 2.adjusted
        self.configuration = config
        
        signupLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            
        }
        
    }
    
    private var signupLabel = UILabel().then {
        $0.font = .suitBoldFont(ofSize: 12)
        $0.textColor = .stepinWhite100
        $0.text = "home_signup_button_title".localized()
    }
}
