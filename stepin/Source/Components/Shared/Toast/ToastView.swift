import UIKit
import SnapKit
import Then

enum ToastViewIconType {
    case blueCheck
    case redX
}

class ToastView: UIView {
    
    init(title: String, icon: ToastViewIconType) {
        super.init(frame: .zero)
        self.descriptionLabel.text = title
        self.iconImageView.image = icon == .redX ? ImageLiterals.icToastX: ImageLiterals.icToastCheck
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinGray797979
        self.addSubviews([iconImageView, descriptionLabel])
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 16))
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 10))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
        }
    }
    
    private var descriptionLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
    }
    private var iconImageView = UIImageView()
}
