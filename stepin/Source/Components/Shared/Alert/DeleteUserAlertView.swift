import UIKit
import SDSKit
import Foundation
import SnapKit
import Then
import Kingfisher

class DeleteUserAlertView: BaseOKAlertView {
    
    override init() {
        super.init()
        setDeleteUserAlertLayout()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setData(profilePath: String, userName: String) {
        if profilePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profilePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = userName
    }
    
    private func setDeleteUserAlertLayout() {
        self.addSubviews([profileImageView, userNameLabel, descriptionLabel])
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 24))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 40) / 2
        profileImageView.clipsToBounds = true
        
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(ScreenUtils.setWidth(value: 8))
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(descriptionLabel.snp.top).inset(ScreenUtils.setWidth(value: 16))
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 16))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(okButton.snp.top).inset(ScreenUtils.setWidth(value: 24))
        }
    }
    
    private var profileImageView = UIImageView()
    private var userNameLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
    }
    private var descriptionLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "alert_view_delete_follower_description".localized()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
}
