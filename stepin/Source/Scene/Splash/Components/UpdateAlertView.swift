import UIKit
import SDSKit
import Then
import SnapKit

class UpdateAlertView: UIView {
    var quitButtonCompletion: (() -> Void)?
    var linkButtonCompletion: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.addSubviews([blurView, contentBackGroundView])
        blurView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        contentBackGroundView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 272))
            $0.height.equalTo(ScreenUtils.setWidth(value: 210))
        }
        contentBackGroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        contentBackGroundView.clipsToBounds = true
        
        contentBackGroundView.addSubviews([titleLabel, descriptionLabel, quitButton, okButton])
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 40))
            $0.centerX.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        quitButton.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview()
            $0.trailing.equalTo(self.okButton.snp.leading)
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
            $0.width.equalTo(ScreenUtils.setWidth(value: 136))
        }
        okButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        
    }
    
    @objc private func didQuitButtonTapped() {
        guard let completion = quitButtonCompletion else {return}
        completion()
    }
    
    @objc private func didLinkButtonTapped() {
        guard let completion = linkButtonCompletion else {return}
        completion()
    }
    
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var contentBackGroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    private let titleLabel = UILabel().then {
        $0.textColor = .PrimaryWhiteNormal
        $0.font = SDSFont.h1.font
        $0.text = "splash_new_version_released_title".localized()
    }
    private let descriptionLabel = UILabel().then {
        $0.textColor = .PrimaryWhiteNormal
        $0.font = SDSFont.body.font
        $0.text = "splash_new_version_released_description".localized()
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private lazy var quitButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.layer.borderColor = UIColor.PrimaryWhiteAlternative.cgColor
        $0.layer.cornerRadius = 24.adjusted
        $0.setTitle("splash_new_version_quit_button_title".localized(),
                    for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.addTarget(self,
                     action: #selector(didQuitButtonTapped),
                     for: .touchUpInside)
    }
    private lazy var okButton = UIButton().then {
        $0.backgroundColor = .PrimaryWhiteAlternative
        $0.layer.borderColor = UIColor.PrimaryWhiteAlternative.cgColor
        $0.layer.cornerRadius = 24.adjusted
        $0.setTitle("splash_new_version_link_button_title".localized(),
                    for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.addTarget(self,
                     action: #selector(didLinkButtonTapped),
                     for: .touchUpInside)
    }
}
