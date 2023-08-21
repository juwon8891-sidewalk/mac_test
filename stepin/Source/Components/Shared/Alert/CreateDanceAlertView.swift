import UIKit
import SnapKit
import Then

class CreateDanceAlertView: BaseOKAlertView {
    override init() {
        super.init()
        setLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.alertContentView.addSubviews([warningIconImageView, warningTitleLabel, warningDescriptionLabel])
        warningIconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 27))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        
        warningTitleLabel.snp.makeConstraints {
            $0.top.equalTo(warningIconImageView.snp.bottom).offset(ScreenUtils.setWidth(value: 8))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        warningDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(warningTitleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
    }
    
    private var warningIconImageView = UIImageView(image: ImageLiterals.icYellowReport)
    private var warningTitleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinYellow
        $0.text = "new_dance_view_upload_alert_title".localized()
    }
    private var warningDescriptionLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "new_dance_view_upload_alert_description".localized()
        $0.numberOfLines = 0
    }
}
