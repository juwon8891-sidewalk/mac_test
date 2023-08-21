import UIKit
import SnapKit
import Then

class BaseOKAlertView: UIView {
    var okButtonTappedCompletion: (() -> Void)?
    var cancelButtonTappedCompletion: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setBaseLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func didOkButtonDidTappeed() {
        guard let completion = okButtonTappedCompletion else {return}
        completion()
    }
    
    @objc private func didCancelButtonDidTapped() {
        guard let completion = cancelButtonTappedCompletion else {return}
        completion()
    }
    
    private func setBaseLayout() {
        self.backgroundColor = .stepinBlack50
        self.addSubview(alertContentView)

        alertContentView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 272))
            $0.height.equalTo(ScreenUtils.setWidth(value: 241))
        }
        self.alertContentView.addSubviews([okButton,
                                      cancelButton])
        okButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 112))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 112))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
            
        }
        self.clipsToBounds = true
        self.okButton.addTarget(self, action: #selector(didOkButtonDidTappeed), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(didCancelButtonDidTapped), for: .touchUpInside)
        
    }

    
    internal var alertContentView = UIView().then {
        $0.backgroundColor = .stepinBlack100
        $0.layer.borderWidth = ScreenUtils.setWidth(value: 1)
        $0.layer.borderColor = UIColor.stepinWhite40.cgColor
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
    }
    
    internal var okButton = UIButton().then {
        $0.backgroundColor = .stepinWhite40
        $0.layer.cornerRadius = 24.adjusted
        var config = UIButton.Configuration.plain()
        config.attributedTitle = "alert_view_ok_title".localized().setAttributeString(textColor: .stepinWhite100, font: .suitMediumFont(ofSize: 16))
        $0.configuration = config
    }
    internal var cancelButton = UIButton().then {
        $0.backgroundColor = .stepinWhite0
        $0.layer.cornerRadius = 24.adjusted
        $0.layer.borderWidth = ScreenUtils.setWidth(value: 2)
        $0.layer.borderColor = UIColor.stepinWhite40.cgColor
        var config = UIButton.Configuration.plain()
        config.attributedTitle = "alert_report_cancel".localized().setAttributeString(textColor: .stepinWhite100, font: .suitMediumFont(ofSize: 16))
        $0.configuration = config
    }
}
