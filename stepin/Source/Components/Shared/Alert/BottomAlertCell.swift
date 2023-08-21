import UIKit
import SDSKit
import SnapKit
import Then

class BottomAlertCell: UIView {
    
    init(title: String) {
        super.init(frame: .zero)
        setLayout()
        self.cellTitleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.addSubviews([cellTitleLabel, bottomGradient])
        cellTitleLabel.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        bottomGradient.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private var cellTitleLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .SystemBlue
    }
    private var bottomGradient = HorizontalGradientView(width: 343)
}
