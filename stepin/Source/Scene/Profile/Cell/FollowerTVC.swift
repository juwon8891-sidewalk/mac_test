import UIKit
import SDSKit
import RxSwift

class FollowerTVC: BaseFollowerTVC {
    var deleteButtonCompletion: ((Int) -> Void)?
    var followButtonCompletion: ((Int) -> Void)?
    static let identifier: String = "FollowerTVC"
    var cellType: FollowerViewType?
    
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
        self.followButton.removeFromSuperview()
        self.generalButton.setTitle("", for: .normal)
    }
    
    internal func setData(profiePath: String,
                          stepinId: String,
                          isFollow: Bool,
                          tag: Int) {
        if self.cellType == .other {
            self.generalButton.isHidden = true
        } else {
            self.generalButton.isHidden = false
        }
        if stepinId == UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) {
            self.followButton.isHidden = true
        } else {
            self.followButton.isHidden = false
        }
        
        self.tag = tag
        if profiePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profiePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = stepinId
        setFollowerCellLayout(isFollow: isFollow)
    }
    
    @objc private func didDeleteButtonTapped() {
        guard let completion = deleteButtonCompletion else {return}
        completion(self.tag)
    }
    
    @objc private func didFollowButtonTapped() {
        guard let completion = followButtonCompletion else {return}
        completion(self.tag)
    }
    
    private func setFollowerCellLayout(isFollow: Bool) {
        super.setLayout()
        if !isFollow {
            self.addSubview(followButton)
            followButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(self.userNameLabel.snp.trailing).offset(ScreenUtils.setWidth(value: 20))
                $0.height.equalTo(ScreenUtils.setWidth(value: 15))
            }
            self.setDeleteButton()
        } else {
            self.setDeleteButton()
        }
    }
    
    private func setDeleteButton() {
        self.generalButton.setTitle("show_follow_delete_button_title".localized(), for: .normal)
        self.generalButton.setTitleColor(.stepinWhite100, for: .normal)
        self.generalButton.backgroundColor = .stepinWhite40
        self.generalButton.addTarget(self, action: #selector(didDeleteButtonTapped), for: .touchUpInside)
        self.followButton.addTarget(self, action: #selector(didFollowButtonTapped), for: .touchUpInside)
        
    }
    
    private var followButton = UIButton().then {
        $0.setTitle("show_follow_blue_follow_button_title".localized(), for: .normal)
        $0.setTitleColor(.SystemBlue, for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 12)
    }
}
