import UIKit
import SnapKit
import Then

class CustomSearchBar: UIView {
    
    init(width: CGFloat) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width,
                                                             height: ScreenUtils.setWidth(value: 30))))
        self.backgroundColor = .stepinBlack100
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.addSubview(textField)
        textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.stepinWhite100.cgColor
        self.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
    }
    
    internal var textField = UITextField().then {
        $0.placeholder = "searchbar_placeholer_title".localized()
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
    }
}
