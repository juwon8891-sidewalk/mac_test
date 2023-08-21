import UIKit
import SDSKit
import RxSwift

class BlockPageHeaderView: BaseProfileCollectionHeaderView {
    static let identifier: String = "BlockPageHeaderView"
    
    override init() {
        super.init()
        setLayout()
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 468)))
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()
    }
    
    internal func setData(profileImage: String,
                          userName: String) {
        if profileImage == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profileImage) else { return }
            self.profileImageView.kf.setImage(with: url)
        }
        self.idLabel.text = userName
    }
    
    private func setLayout() {
        self.addSubviews([blockButton, boostProfileButton, dancesButton, followersButton, followingButton])
        idLabel.snp.remakeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(ScreenUtils.setHeight(value: 4))
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(followersButton.snp.top).offset(ScreenUtils.setHeight(value: -12))
        }
        followersButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(idLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 12))
            $0.width.equalTo(ScreenUtils.setWidth(value: 49))
            $0.height.equalTo(ScreenUtils.setWidth(value: 38))
            $0.bottom.equalTo(self.blockButton.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        dancesButton.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 12))
            $0.trailing.equalTo(followersButton.snp.leading).inset(ScreenUtils.setWidth(value: -40))
            $0.leading.equalToSuperview().inset(ScreenUtils.setWidth(value: 73))
            $0.height.equalTo(ScreenUtils.setWidth(value: 38))
            $0.bottom.equalTo(self.blockButton.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        followingButton.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 12))
            $0.leading.equalTo(followersButton.snp.trailing).inset(ScreenUtils.setWidth(value: -40))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 73))
            $0.height.equalTo(ScreenUtils.setWidth(value: 38))
            $0.bottom.equalTo(self.blockButton.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        blockButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 64))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.width.equalTo(ScreenUtils.setWidth(value: 114))
            $0.trailing.equalTo(boostProfileButton.snp.leading).inset(ScreenUtils.setWidth(value: -20))
            $0.bottom.equalTo(self.bottomGradientView.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        blockButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        boostProfileButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 64))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.bottom.equalTo(self.bottomGradientView.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        boostProfileButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        self.backgroundVideoView.isHidden = true
    }
    
    private var blockButton = ProfileButton(type: .blockUser)
    private var boostProfileButton = ProfileButton(type: .boost)
    private var dancesButton = UserInfoButton(type: .dances)
    private var followersButton = UserInfoButton(type: .followers)
    private var followingButton = UserInfoButton(type: .following)
}
