import UIKit
import SnapKit
import Then
import RxSwift

class BaseAlertView: UIView {
    var disposeBag = DisposeBag()
    var didCancelButtonTappedCompletion: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .stepinBlack100
        setBaseLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    @objc private func didCancelButtonTapped() {
        guard let completion = didCancelButtonTappedCompletion else {return}
        completion()
    }
    
    private func setBaseLayout() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.frame
        self.addSubview(blurView)
        blurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 272))
            $0.height.equalTo(ScreenUtils.setWidth(value: 372))
        }
        backgroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        backgroundView.clipsToBounds = true
        self.backgroundView.addSubviews([alertImageView,
                                         alertTitleLabel,
                                         alertContentView,
                                         cancelButton])
        alertImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 28))
            $0.width.equalTo(ScreenUtils.setWidth(value: 18))
            $0.height.equalTo(ScreenUtils.setWidth(value: 16))
        }
        alertTitleLabel.snp.makeConstraints {
            $0.top.equalTo(alertImageView.snp.bottom).offset(ScreenUtils.setWidth(value: 12))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        alertContentView.snp.makeConstraints {
            $0.top.equalTo(alertTitleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(cancelButton.snp.top)
        }
        cancelButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(ScreenUtils.setHeight(value: 16))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.clipsToBounds = true
        
    }
    internal var backgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
        $0.layer.borderWidth = ScreenUtils.setWidth(value: 1)
        $0.layer.borderColor = UIColor.stepinWhite40.cgColor
    }
    internal var alertImageView = UIImageView(image: ImageLiterals.icReport)
    internal var alertTitleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinRed100
    }
    internal var alertContentView = UIView().then {
        $0.backgroundColor = .clear
    }
    internal lazy var cancelButton = UIButton().then {
        $0.addTarget(self,
                     action: #selector(didCancelButtonTapped),
                     for: .touchUpInside)
        $0.backgroundColor = .stepinWhite40
        var config = UIButton.Configuration.plain()
        config.attributedTitle = "alert_report_cancel".localized().setAttributeString(textColor: .stepinWhite100, font: .suitMediumFont(ofSize: 16))
        $0.configuration = config
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
    }
}
