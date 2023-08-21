import UIKit
import SnapKit
import Then
import RxSwift
import RxGesture
import RxCocoa

class ShowFollowerTabbar: UIView {
    var didFollowerTabClickedCompletion: (() -> Void)?
    var didFollowingTabClickedCompletion: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setLayout()
        bindGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func didMoveToTab(xPosition: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.bottomGradientView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: xPosition))
            }
        }
        if xPosition >= UIScreen.main.bounds.width / 2 - ScreenUtils.setWidth(value: 30) {
            changeFollowerLabelColor(color: .stepinWhite40)
            changeFollowingLabelColor(color: .stepinWhite100)
        } else {
            changeFollowerLabelColor(color: .stepinWhite100)
            changeFollowingLabelColor(color: .stepinWhite40)
        }
    }
    
    internal func changeFollowerLabelColor(color: UIColor) {
        followerLabel.textColor = color
    }
    
    internal func changeFollowingLabelColor(color: UIColor) {
        followingLabel.textColor = color
    }
    
    private func bindGesture() {
        self.followerTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didFollowerTabClicked)))
        self.followingTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didFollowingTabClicked)))
        
    }
    @objc private func didFollowingTabClicked() {
        guard let followingTabCompletion = didFollowingTabClickedCompletion else {return}
        followingTabCompletion()
    }
    @objc private func didFollowerTabClicked() {
        guard let followerTabCompletion = didFollowerTabClickedCompletion else {return}
        followerTabCompletion()
    }
    private func setLayout() {
        self.addSubviews([followerTab, followingTab, bottomGradientView])
        self.followerTab.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width / 2.0)
        }
        self.followingTab.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width / 2.0)
        }
        followerTab.addSubview(followerLabel)
        followerLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        followingTab.addSubview(followingLabel)
        followingLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        bottomGradientView.snp.makeConstraints {
            $0.top.equalTo(followerLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 8))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 18))
        }
    }
    
    private var followerTab = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    private var followerLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.text = "show_follow_follower_tab_title".localized()
    }
    
    private var followingTab = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    
    private var followingLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.text = "show_follow_following_tab_title".localized()
    }
    private var bottomGradientView = HorizontalGradientView(width: ScreenUtils.setWidth(value: 172))
    
}
