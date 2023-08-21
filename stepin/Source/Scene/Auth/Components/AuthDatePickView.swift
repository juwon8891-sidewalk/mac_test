import UIKit
import Then
import SnapKit

class AuthDatePickView: GeneralAuthTextView {
    
    override init() {
        super.init(frame: .zero)
        self.setLabelLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setDateLabel(date: String) {
        self.dateLabel.text = date
        self.dateLabel.textColor = .stepinWhite100
    }
    
    internal func setDateLabelDefault() {
        self.dateLabel.text = "auth_birthDate_placeholder".localized()
        self.dateLabel.textColor = .stepinWhite40
    }
    
    internal func setBottomLineColor(color: UIColor) {
        self.bottomLine.backgroundColor = color
    }
    
    internal func setBottomText(title: String, color: UIColor) {
        self.bottomText.text = title
        self.bottomText.textColor = color
    }
    
    private func setLabelLayout() {
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
    }
    
    internal func setPlaceHolderColor() {
        self.dateLabel.textColor = .stepinWhite40
    }
    
    internal func setLabelColor() {
        self.dateLabel.textColor = .stepinWhite100
    }
    
    private var dateLabel = UILabel().then {
        $0.text = "auth_birthDate_placeholder".localized()
        $0.font = .suitMediumFont(ofSize: 20)
        $0.textColor = .stepinWhite40
    }
}

