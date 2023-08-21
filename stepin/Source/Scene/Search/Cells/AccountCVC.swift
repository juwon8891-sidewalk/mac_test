import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxRelay

class AccountCVC: UICollectionViewCell {
    static let identifier: String = "AccountCVC"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
        self.userNameLabel.text = ""
    }
    
    internal func setData(profilePath: String, userName: String) {
        if profilePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profilePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = userName
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([profileImageView, userNameLabel])
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        profileImageView.clipsToBounds = true
        userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.centerY.equalTo(self.profileImageView)
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
    }
    
    private var profileImageView = UIImageView()
    private var userNameLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    
}
