import UIKit
import SDSKit
import RxSwift
import RxRelay
import Kingfisher
import SnapKit
import Then

class BlockedUserVC: UIViewController {
    var blockedViewModel: BlockedUserViewModel?
    var disposeBag = DisposeBag()
    internal var stepinId: String = ""
    internal var profilePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setData()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let output = blockedViewModel?.transform(from: .init(unblockButton: self.unblockButton,
                                                             didUnlockButtonTapped: self.unblockButton.rx.tap.asObservable()),
                                                 disposeBag: disposeBag)
        
        output?.unblockState
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                print(self?.unblockButton.isSelected)
                self!.unblockButton.isSelected = !self!.unblockButton.isSelected
                if state {
                    self?.isSelectedBlockButton()
                } else {
                    self?.isUnselectedBlockButton()
                }
            })
            .disposed(by: disposeBag)
        
        self.navigationView.backButtonCompletion = {
            self.navigationController?.popViewController(animated: true)
        }
    }
    private func setData() {
        if profilePath == "" {
            profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: self.profilePath) else {return}
            profileImageView.kf.setImage(with: url)
        }
        self.stepinIdLabel.text = self.stepinId
        self.navigationView.setTitle(title: self.stepinId)
    }
    
    private func isSelectedBlockButton() {
        self.unblockButton.backgroundColor = .stepinWhite40
        self.unblockButton.layer.borderWidth = 0
        self.blockedLabel.text = "block_view_block_description".localized() + "\(stepinId)."
    }
    
    private func isUnselectedBlockButton() {
        self.unblockButton.backgroundColor = .stepinBlack100
        self.unblockButton.layer.borderWidth = 1
        self.unblockButton.layer.borderColor = UIColor.stepinWhite100.cgColor
        self.blockedLabel.text = "block_view_unblock_description".localized() + "\(stepinId)."
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, profileImageView, stepinIdLabel, dancesButton, followersButton, followingButton, unblockButton, boostButton, bottomGradientView, blockedLabel])
        navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        navigationView.setRightButtonImage(image: ImageLiterals.icMore)
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 72) / 2
        profileImageView.clipsToBounds = true
        
        stepinIdLabel.snp.remakeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(ScreenUtils.setHeight(value: 8))
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(followersButton.snp.top).offset(ScreenUtils.setHeight(value: -35))
        }
        followersButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 49))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
            $0.bottom.equalTo(self.unblockButton.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        dancesButton.snp.makeConstraints {
            $0.trailing.equalTo(followersButton.snp.leading).inset(ScreenUtils.setWidth(value: -40))
            $0.leading.equalToSuperview().inset(ScreenUtils.setWidth(value: 73))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
            $0.bottom.equalTo(self.unblockButton.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        followingButton.snp.makeConstraints {
            $0.leading.equalTo(followersButton.snp.trailing).inset(ScreenUtils.setWidth(value: -40))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 73))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
            $0.bottom.equalTo(self.unblockButton.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        unblockButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 64))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.width.equalTo(ScreenUtils.setWidth(value: 114))
            $0.trailing.equalTo(boostButton.snp.leading).inset(ScreenUtils.setWidth(value: -20))
            $0.bottom.equalTo(self.bottomGradientView.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        unblockButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        boostButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 64))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.bottom.equalTo(self.bottomGradientView.snp.top).inset(ScreenUtils.setHeight(value: -20))
        }
        boostButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        bottomGradientView.snp.makeConstraints {
            $0.top.equalTo(unblockButton.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        blockedLabel.snp.makeConstraints {
            $0.top.equalTo(bottomGradientView.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 138))
        }
        self.blockedLabel.text = "block_view_block_description".localized() + "\(stepinId)."
    }
    
    private var navigationView = TitleNavigationView()
    private var profileImageView = UIImageView()
    private var stepinIdLabel = UILabel()
    private var dancesButton = UIButton().then {
        $0.setTitle("block_view_Dances_button_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.titleLabel?.font = .suitLightFont(ofSize: 12)
    }
    private var followersButton = UIButton().then {
        $0.setTitle("block_view_followers_button_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.titleLabel?.font = .suitLightFont(ofSize: 12)
    }
    private var followingButton = UIButton().then {
        $0.setTitle("block_view_following_button_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.titleLabel?.font = .suitLightFont(ofSize: 12)
    }
    private var unblockButton = ProfileButton(type: .follow).then {
        $0.backgroundColor = .stepinWhite40
        $0.setTitle("block_view_unblock_button_title".localized(), for: .normal)
        $0.setTitle("block_view_block_button_title".localized(), for: .selected)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.layer.borderWidth = 0
    }
    private var boostButton = ProfileButton(type: .boost).then {
        $0.backgroundColor = .stepinWhite40
        $0.setTitleColor(.stepinWhite40, for: .normal)
        $0.layer.borderWidth = 0
    }
    private var bottomGradientView = HorizontalGradientView(width: ScreenUtils.setWidth(value: 343))
    private var blockedLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    
    
}
