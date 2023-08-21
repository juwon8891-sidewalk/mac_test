import Foundation
import UIKit
import SDSKit
import SnapKit
import Then
import Kingfisher

final class ProfileHeaderView: UICollectionReusableView {
    var followersButtonTapCompletion: (() -> Void)?
    var followingButtonTapCompletion: (() -> Void)?
    var leftButtonTapCompletion: ((Bool) -> Void)?
    var rightButtonTapCompletion: ((Bool) -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
    }
    
    func bindData(data: MyPageData,
                  profileState: ProfileViewState) {
        if let url = URL(string: data.profileURL ?? "") {
            self.profileImageView.kf.setImage(with: url)
        }
        userNameLabel.text = data.identifierName
        danceInfoButton.bindText(category: "mypage_dances_button_title".localized(),
                                 count: data.danceCount)
        followerButton.bindText(category: "mypage_followers_button_title".localized(),
                                 count: data.followerCount)
        followingButton.bindText(category: "mypage_following_button_title".localized(),
                                 count: data.followingCount)
        
        if profileState == .other {
            self.leftButton.isSelected = data.isFollowed
        }
        
        self.setProfileState(profileState)
    }
    
    @objc private func didFollowerButtonTap() {
        guard let followersButtonTapCompletion else {return}
        followersButtonTapCompletion()
    }
    
    @objc private func didFollowingButtonTap() {
        guard let followingButtonTapCompletion else {return}
        followingButtonTapCompletion()
    }
    
    @objc private func didLeftButtonTap() {
        guard let leftButtonTapCompletion else {return}
        leftButtonTapCompletion(leftButton.isSelected)
    }
    
    @objc private func didRightButtonTap() {
        guard let rightButtonTapCompletion else {return}
        rightButtonTapCompletion(rightButton.isSelected)
    }
    
    func setProfileState(_ state: ProfileViewState) {
        DispatchQueue.main.async {
            switch state {
            case .my, .backButtonMy:
                self.setViewHiddenState(state: false)
                self.leftButton.setTitle("mypage_editProfile_button_title".localized(),
                                         for: .normal)
                self.rightButton.setTitle("mypage_shareProfileProfile_button_title".localized(),
                                          for: .normal)
            case .other:
                self.setViewHiddenState(state: false)
                self.leftButton.setTitle("mypage_follow_button_title".localized(), for: .normal)
                self.leftButton.setTitleColor(.PrimaryWhiteNormal, for: .normal)
                self.leftButton.setBackgroundColor(.clear, for: .normal)
                self.leftButton.setTitle("mypage_following_button_title".localized(), for: .selected)
                self.leftButton.setBackgroundColor(.PrimaryWhiteNormal, for: .selected)
                self.leftButton.setTitleColor(.PrimaryBlackNormal, for: .selected)
                self.rightButton.setTitle("mypage_boost_button_title".localized(),
                                          for: .normal)
            case .block:
                self.setViewHiddenState(state: true)
                self.danceInfoButton.bindText(category: "mypage_dances_button_title".localized(),
                                              count: nil)
                self.followerButton.bindText(category: "mypage_followers_button_title".localized(),
                                             count: nil)
                self.followingButton.bindText(category: "mypage_following_button_title".localized(),
                                              count: nil)
                self.leftButton.setTitle("mypage_unblock_button_title".localized(),
                                         for: .normal)
                
            }
        }
    }
    
    private func setViewHiddenState(state: Bool) {
        self.backGroundVideoView.isHidden = state
        self.backGroundImageView.isHidden = state
        self.rightButton.isHidden = state
    }
    
    func setAlphaWithView(alpha: CGFloat) {
        if alpha < 0.9 {
            blackBackgroundView.isHidden = false
            blackBackgroundView.alpha = 1 - alpha
        } else {
            blackBackgroundView.isHidden = true
        }
    }
    
    private func setLayout() {
        self.addSubviews([backGroundVideoView,
                          backGroundImageView,
                          profileImageView,
                          userNameLabel,
                          infoStackView,
                          blackBackgroundView,
                          buttonStackView,
                          bottomGradientView])
        self.buttonStackView.addArrangeSubViews([leftButton, rightButton])
        self.infoStackView.addArrangeSubViews([danceInfoButton, followerButton, followingButton])
        backGroundImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(-5.adjusted)
            $0.top.bottom.equalToSuperview()
        }
        backGroundVideoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(-5.adjusted)
            $0.top.bottom.equalToSuperview()
        }
        backGroundVideoView.addSubview(videoGradientView)
        videoGradientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(-5.adjusted)
            $0.top.bottom.equalToSuperview()
        }
        bottomGradientView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(1)
        }
        leftButton.snp.makeConstraints {
            $0.width.equalTo(114.adjusted)
            $0.height.equalTo(30.adjusted)
        }
        rightButton.snp.makeConstraints {
            $0.width.equalTo(114.adjusted)
            $0.height.equalTo(30.adjusted)
        }
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(bottomGradientView.snp.top).inset(-20.adjusted)
            $0.centerX.equalToSuperview()
        }
        infoStackView.snp.makeConstraints {
            $0.bottom.equalTo(self.buttonStackView.snp.top).inset(-20.adjusted)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
        }
        userNameLabel.snp.makeConstraints {
            $0.bottom.equalTo(infoStackView.snp.top).inset(-12.adjusted)
            $0.centerX.equalToSuperview()
        }
        profileImageView.snp.makeConstraints {
            $0.bottom.equalTo(userNameLabel.snp.top).inset(-8.adjusted)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(72.adjusted)
        }
        blackBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        blackBackgroundView.isHidden = true
    }
    let backGroundImageView = UIImageView(image: ImageLiterals.profileBackground).then {
        $0.backgroundColor = .PrimaryBlackHeavy
    }
    let backGroundVideoView = BaseVideoView(frame: .init(origin: .zero,
                                                         size: .init(width: UIScreen.main.bounds.width + 10.adjusted,
                                                                                            height: 490.adjustedH)))
    let blackBackgroundView = UIView().then {
        $0.backgroundColor = .PrimaryBlackNormal
    }
    let videoGradientView = UIView().then {
        $0.addGradient(to: $0,
                       colors: [UIColor.PrimaryBlackNormal.cgColor,
                                UIColor.PrimaryBlackNormal.withAlphaComponent(0).cgColor],
                       startPoint: .bottomCenter,
                       endPoint: .topCenter)
    }
    
    let profileImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 36.adjusted
        $0.image = SDSIcon.icDefaultProfile
    }
    let userNameLabel = UILabel().then {
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
        $0.text = "userName"
    }
    let infoStackView = UIStackView().then {
        $0.distribution = .equalSpacing
        $0.spacing = 40
        $0.axis = .horizontal
        $0.backgroundColor = .clear
    }
    let danceInfoButton = ProfileInfoButton().then {
        $0.bindText(category: "mypage_dances_button_title".localized(),
                    count: 0)
    }
    lazy var followerButton = ProfileInfoButton().then {
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                       action: #selector(didFollowerButtonTap)))
        $0.bindText(category: "mypage_followers_button_title".localized(),
                    count: 0)
    }
    lazy var followingButton = ProfileInfoButton().then {
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                       action: #selector(didFollowingButtonTap)))
        $0.bindText(category: "mypage_following_button_title".localized(),
                    count: 0)
    }
    lazy var leftButton = SDSCategoryButton(type: .extraBold).then {
        $0.addTarget(self,
                     action: #selector(didLeftButtonTap),
                     for: .touchUpInside)
        $0.buttonState = .line
        $0.layer.cornerRadius = 15.adjusted
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
        $0.setTitleColor(.PrimaryWhiteNormal, for: .normal)
    }
    lazy var rightButton = SDSCategoryButton(type: .extraBold).then {
        $0.addTarget(self,
                     action: #selector(didRightButtonTap),
                     for: .touchUpInside)
        $0.buttonState = .line
        $0.layer.cornerRadius = 15.adjusted
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
        $0.setTitleColor(.PrimaryWhiteNormal, for: .normal)
    }
    let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20.adjusted
        $0.distribution = .equalSpacing
    }
    let bottomGradientView = UIView().then {
        $0.addGradient(size: .init(width: UIScreen.main.bounds.width - 32.adjusted,
                                   height: 1),
                       colors: [UIColor.white.withAlphaComponent(0).cgColor,
                                                     UIColor.white.withAlphaComponent(0.4).cgColor,
                                                     UIColor.white.withAlphaComponent(0).cgColor],
                       startPoint: .centerLeft,
                       endPoint: .centerRight)
    }
    
}
