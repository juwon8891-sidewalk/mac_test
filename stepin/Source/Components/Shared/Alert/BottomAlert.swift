import UIKit
import Then
import SnapKit


class BottomAlert: UIView {
    var cancelCompletion: (() -> Void)?
    init(size: CGSize) {
        super.init(frame: CGRect(origin: .zero, size: size))
        self.backgroundColor = .stepinBlack100
        self.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setLayout() {
        self.addSubviews([alertTitleLabel, contentView, cancelButton])
        alertTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(alertTitleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(cancelButton.snp.top)
        }
        cancelButton.snp.makeConstraints {
//            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setHeight(value: 16))
            $0.leading.equalToSuperview().offset(ScreenUtils.setHeight(value: 16))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setHeight(value: 16))
        }
        cancelButton.addTarget(self, action: #selector(didCancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func didCancelButtonTapped() {
        guard let completion = cancelCompletion else {return}
        completion()
    }
    
    internal var alertTitleLabel = UILabel().then {
        $0.backgroundColor = .stepinBlack100
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }

    internal var contentView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    
    internal var cancelButton = UIButton().then {
        $0.backgroundColor = .stepinWhite40
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 24)
        $0.setTitle("edit_mypage_bottom_alert_cancel".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
    }
}
