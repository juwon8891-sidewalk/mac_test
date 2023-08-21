import UIKit
import SnapKit
import Then

class WhiteBlurButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(title: String) {
        super.init(frame: .zero)
        setLayout(title: title)
    }
    
    private func setLayout(title: String) {
        self.backgroundColor = .stepinWhite100
        self.setTitle(title, for: .normal)
        self.setTitleColor(.stepinBlack100, for: .normal)
        self.titleLabel?.font = .ShrikhandRegular(ofSize: 20)
    }
    private func setButtonBlur() {
        self.layer.shadowColor = UIColor.stepinWhite100.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = ScreenUtils.setWidth(value: 15)
        self.clipsToBounds = false
        self.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
    }
    
}

