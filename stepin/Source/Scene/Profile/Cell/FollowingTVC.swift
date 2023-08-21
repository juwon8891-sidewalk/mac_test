import UIKit
import SDSKit

class FollowingTVC: BaseFollowerTVC {
    var followButtonCompletion: ((Int, Bool) -> Void)?
    static let identifier: String = "FollowingTVC"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
        self.userNameLabel.text = nil
        self.generalButton.isSelected = true
    }
    
    internal func setData(profiePath: String,
                          stepinId: String,
                          isFollow: Bool,
                          tag: Int) {
        if stepinId == UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) {
            self.generalButton.isHidden = true
        } else {
            self.generalButton.isHidden = false
        }
        self.tag = tag
        if profiePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profiePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = stepinId
        self.generalButton.isSelected = isFollow
        setFollowerCellLayout()
    }
    
    private func setFollowerCellLayout() {
        super.setLayout()
        self.setFollowButtonLayout()
        self.isSelectedFollowButton()
    }
    
    private func setFollowButtonLayout() {
        self.generalButton.setTitle("show_follow_following_button_title".localized(), for: .selected)
        self.generalButton.setTitleColor(.stepinBlack100, for: .selected)
        self.generalButton.setTitle("mypage_follow_button_title".localized(), for: .normal)
        self.generalButton.setTitleColor(.stepinWhite100, for: .normal)
        
        self.generalButton.addTarget(self, action: #selector(didFollowButtonTapped), for: .touchUpInside)
    }
    
    private func isSelectedFollowButton() {
        if self.generalButton.isSelected {
            self.generalButton.backgroundColor = .stepinWhite100
            self.generalButton.layer.borderWidth = 0
        } else {
            self.generalButton.backgroundColor = .stepinBlack100
            self.generalButton.layer.borderWidth = 1
            self.generalButton.layer.borderColor = UIColor.stepinWhite100.cgColor
        }
    }
    
    @objc private func didFollowButtonTapped() {
        guard let completion = followButtonCompletion else {return}
        completion(self.tag, generalButton.isSelected)
    }
}
