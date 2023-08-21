import Foundation
import UIKit
import SDSKit
import Then
import SnapKit

class SuperShortFormReduceView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    func bindData(profileImagePath: String,
                  userName: String) {
        if let url = URL(string: profileImagePath) {
            self.profileImageView.kf.setImage(with: url)
        } else {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        }
        self.userNameLabel.text = userName
    }
    
    private func setLayout() {
        self.clipsToBounds = true
        self.addSubviews([backgroundGradientView, profileImageView, userNameLabel])
        backgroundGradientView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
        }
        profileImageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(12.adjusted)
            $0.width.height.equalTo(40.adjusted)
        }
        
        profileImageView.layer.cornerRadius = 20.adjusted
        profileImageView.clipsToBounds = true
        
        userNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).inset(-12.adjusted)
        }
    }
    
    let backgroundGradientView = UIView().then {
        $0.addGradient(size: .init(width: 300.adjusted,
                                   height: 78.adjusted),
                       colors: [UIColor.PrimaryBlackNormal.withAlphaComponent(0.5).cgColor,
                                UIColor.clear.cgColor],
                       startPoint: .bottomCenter,
                       endPoint: .topCenter)
    }
    
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    let userNameLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
}
