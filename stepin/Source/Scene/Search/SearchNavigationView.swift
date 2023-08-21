import UIKit
import SnapKit
import Then

class SearchNavigationView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    
    private func setLayout() {
        self.addSubviews([backButton, textField, searchButton])
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.textField.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.leading.equalTo(backButton.snp.trailing)
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.trailing.equalTo(searchButton.snp.leading)
        }
        self.textField.layer.borderWidth = 1
        self.textField.layer.borderColor = UIColor.stepinWhite100.cgColor
        self.textField.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        self.textField.setLeftPaddingPoints(ScreenUtils.setWidth(value: 16))
        self.searchButton.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
    }
    
    internal func setTitle(text: String) {
        self.textField.text = text
    }
    
    internal var backButton = UIButton().then {
        $0.setImage(ImageLiterals.icWhiteArrow, for: .normal)
    }
    internal var textField = UITextField().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.tintColor = .stepinWhite100
        $0.placeholder = "searchView_navigation_place_holder_title".localized()
    }
    internal var searchButton = UIButton().then {
        $0.setImage(ImageLiterals.icSearch, for: .normal)
    }
}
